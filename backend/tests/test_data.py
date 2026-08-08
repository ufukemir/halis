"""OTA veri ucu testleri."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_data_bundle_iki_tabloyu_verir():
    resp = client.get("/v1/data")
    assert resp.status_code == 200
    body = resp.json()
    assert "codes" in body["e_codes"]
    assert len(body["e_codes"]["codes"]) >= 304
    assert "entries" in body["ingredients"]
    assert body["e_codes"]["version"]


def test_data_repo_kopyasiyla_ikiz():
    # backend/data kopyası repo kökündeki data/ ile senkron olmalı
    # (CONTRIBUTING veri kuralı). Deploy'da yalnız backend/ gittiği için
    # kopya şart; bu test unutulan senkronu yakalar.
    import json
    from pathlib import Path

    root = Path(__file__).parent.parent.parent / "data"
    backend = Path(__file__).parent.parent / "data"
    if not root.exists():
        return  # deploy ortamı: repo kökü yok, kontrol atlanır
    for name in ("e_codes_v0.json", "ingredients_v0.json"):
        a = json.loads((root / name).read_text(encoding="utf-8"))
        b = json.loads((backend / name).read_text(encoding="utf-8"))
        assert a == b, f"{name}: data/ ile backend/data/ farklı — senkronla!"
