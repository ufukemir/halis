"""Sunucu tarafı kota + premium durumu (SQLite).

İlke: kota istemcide de sayılır (UX için), ama LLM maliyetinin asıl bekçisi
burasıdır — cihaz kimliği başına aylık ücretsiz analiz sınırı. Premium durumu
RevenueCat webhook'undan beslenir; cihaz kimliği, uygulamadaki RevenueCat
`appUserID` ile aynıdır (mağaza yapılandırılmamış istemcilerde yerel UUID —
o kimlikler hiçbir zaman premium olamaz, ücretsiz katman kuralları uygulanır).

Kota aşımı istemciyi BLOKE ETMEZ: uygulama 402 aldığında ham OCR metniyle
tamamen yerel analize düşer (normalize_api.dart sözleşmesi).
"""

import os
import sqlite3
import threading
from datetime import datetime, timezone

DB_PATH = os.environ.get("HALIS_DB", "halis.db")

# RevenueCat olay tipleri → premium aktif/pasif geçişleri.
# CANCELLATION yalnız oto-yenilemeyi kapatır; erişim EXPIRATION'a dek sürer.
_ACTIVATING_EVENTS = {
    "INITIAL_PURCHASE",
    "RENEWAL",
    "UNCANCELLATION",
    "PRODUCT_CHANGE",
    "NON_RENEWING_PURCHASE",
}
_DEACTIVATING_EVENTS = {"EXPIRATION"}

_lock = threading.Lock()


def _connect() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.execute(
        "CREATE TABLE IF NOT EXISTS usage ("
        " device_id TEXT NOT NULL,"
        " month TEXT NOT NULL,"
        " count INTEGER NOT NULL DEFAULT 0,"
        " PRIMARY KEY (device_id, month))"
    )
    conn.execute(
        "CREATE TABLE IF NOT EXISTS premium ("
        " app_user_id TEXT PRIMARY KEY,"
        " active INTEGER NOT NULL,"
        " updated_at TEXT NOT NULL)"
    )
    return conn


def _month_key() -> str:
    now = datetime.now(timezone.utc)
    return f"{now.year}-{now.month:02d}"


def is_premium(device_id: str) -> bool:
    with _lock, _connect() as conn:
        row = conn.execute(
            "SELECT active FROM premium WHERE app_user_id = ?", (device_id,)
        ).fetchone()
    return bool(row and row[0])


def used_this_month(device_id: str) -> int:
    with _lock, _connect() as conn:
        row = conn.execute(
            "SELECT count FROM usage WHERE device_id = ? AND month = ?",
            (device_id, _month_key()),
        ).fetchone()
    return row[0] if row else 0


def try_consume(device_id: str, free_quota: int) -> bool:
    """Premium ise sayaç işlemez; değilse kota içindeyse sayacı artırır.

    True → analiz yapılabilir; False → aylık ücretsiz kota doldu.
    """
    if is_premium(device_id):
        return True
    month = _month_key()
    with _lock, _connect() as conn:
        row = conn.execute(
            "SELECT count FROM usage WHERE device_id = ? AND month = ?",
            (device_id, month),
        ).fetchone()
        used = row[0] if row else 0
        if used >= free_quota:
            return False
        conn.execute(
            "INSERT INTO usage (device_id, month, count) VALUES (?, ?, 1)"
            " ON CONFLICT(device_id, month) DO UPDATE SET count = count + 1",
            (device_id, month),
        )
        conn.commit()
    return True


def apply_webhook_event(event: dict) -> bool:
    """RevenueCat webhook olayını premium tablosuna işler.

    Dönüş: olay premium durumunu etkiledi mi (bilinmeyen tipler yok sayılır).
    """
    event_type = event.get("type", "")
    app_user_id = event.get("app_user_id")
    if not app_user_id:
        return False
    if event_type in _ACTIVATING_EVENTS:
        active = 1
    elif event_type in _DEACTIVATING_EVENTS:
        active = 0
    else:
        return False
    now = datetime.now(timezone.utc).isoformat()
    with _lock, _connect() as conn:
        conn.execute(
            "INSERT INTO premium (app_user_id, active, updated_at) VALUES (?, ?, ?)"
            " ON CONFLICT(app_user_id) DO UPDATE SET active = excluded.active,"
            " updated_at = excluded.updated_at",
            (app_user_id, active, now),
        )
        conn.commit()
    return True
