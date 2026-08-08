"""Kota + webhook testleri — LLM çağrısı sahtelenir, gerçek API'ya çıkılmaz."""

from types import SimpleNamespace

import pytest
from fastapi.testclient import TestClient

from app import main, quota
from app.main import NormalizedLabel, app

DEVICE = "test-device-0001"


@pytest.fixture(autouse=True)
def isolated_db(tmp_path, monkeypatch):
    monkeypatch.setattr(quota, "DB_PATH", str(tmp_path / "test.db"))
    monkeypatch.setattr(main, "WEBHOOK_TOKEN", "test-token")
    monkeypatch.setattr(main, "FREE_MONTHLY_QUOTA", 3)
    fake = NormalizedLabel(
        ingredients=["su", "şeker"],
        e_codes=[],
        animal_derived_terms=[],
        alcohol_terms=[],
        ocr_quality="good",
    )
    monkeypatch.setattr(
        main.client.messages,
        "parse",
        lambda **kw: SimpleNamespace(parsed_output=fake),
        raising=False,
    )


client = TestClient(app)


def _normalize(device=DEVICE):
    return client.post(
        "/v1/normalize-label",
        json={"text": "su, şeker, aroma"},
        headers={"X-Device-Id": device},
    )


def _webhook(event, token="test-token"):
    return client.post(
        "/v1/revenuecat-webhook",
        json={"event": event},
        headers={"Authorization": token},
    )


def test_device_id_zorunlu():
    resp = client.post("/v1/normalize-label", json={"text": "su, şeker, aroma"})
    assert resp.status_code == 422


def test_kota_icinde_analiz_calisir():
    resp = _normalize()
    assert resp.status_code == 200
    assert resp.json()["ingredients"] == ["su", "şeker"]


def test_kota_dolunca_402():
    for _ in range(3):
        assert _normalize().status_code == 200
    resp = _normalize()
    assert resp.status_code == 402


def test_kota_cihaz_basina_ayri():
    for _ in range(3):
        _normalize()
    assert _normalize().status_code == 402
    assert _normalize("baska-cihaz-9999").status_code == 200


def test_premium_kotadan_muaf():
    assert _webhook({"type": "INITIAL_PURCHASE", "app_user_id": DEVICE}).status_code == 200
    for _ in range(10):
        assert _normalize().status_code == 200


def test_sure_bitince_premium_duser():
    _webhook({"type": "INITIAL_PURCHASE", "app_user_id": DEVICE})
    _webhook({"type": "EXPIRATION", "app_user_id": DEVICE})
    for _ in range(3):
        _normalize()
    assert _normalize().status_code == 402


def test_iptal_erisimi_kesmez():
    # CANCELLATION oto-yenilemeyi kapatır; erişim EXPIRATION'a dek sürer.
    _webhook({"type": "INITIAL_PURCHASE", "app_user_id": DEVICE})
    resp = _webhook({"type": "CANCELLATION", "app_user_id": DEVICE})
    assert resp.json()["applied"] is False
    for _ in range(5):
        assert _normalize().status_code == 200


def test_webhook_yanlis_token_401():
    resp = _webhook({"type": "INITIAL_PURCHASE", "app_user_id": DEVICE}, token="kotu")
    assert resp.status_code == 401


def test_webhook_token_yapilandirilmamissa_kapali(monkeypatch):
    monkeypatch.setattr(main, "WEBHOOK_TOKEN", "")
    resp = _webhook({"type": "INITIAL_PURCHASE", "app_user_id": DEVICE}, token="")
    assert resp.status_code == 401


def test_quota_endpoint():
    _normalize()
    resp = client.get("/v1/quota", headers={"X-Device-Id": DEVICE})
    body = resp.json()
    assert body == {"premium": False, "free_quota": 3, "used": 1, "remaining": 2}
