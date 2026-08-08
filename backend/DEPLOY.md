# Halis backend — deploy kılavuzu

Backend v1 için ZORUNLU DEĞİL: `HALIS_API_URL` tanımlanmazsa uygulama tamamen
yerel çalışır (OCR + kural motoru). Backend yalnız LLM metin normalizasyonu ve
sunucu tarafı kota içindir; istendiği zaman sonradan devreye alınabilir.

## Ortam değişkenleri

| Değişken | Zorunlu | Açıklama |
|---|---|---|
| `ANTHROPIC_API_KEY` | ✅ | Claude API anahtarı (normalizasyon LLM'i) |
| `HALIS_WEBHOOK_TOKEN` | ✅ (webhook için) | RevenueCat panelindeki Authorization değeriyle birebir aynı olmalı; boşsa webhook ucu 401 döner (bilinçli kapalı) |
| `HALIS_DB` | önerilir | SQLite dosya yolu — KALICI diskte olmalı (aşağıya bak) |
| `HALIS_MODEL` | hayır | Varsayılan `claude-haiku-4-5` |
| `HALIS_FREE_QUOTA` | hayır | Aylık ücretsiz analiz, varsayılan 10 |

## Seçenek A — Azure App Service (B1, AA Terminal tecrübesi)

```bash
cd backend
az webapp up --name halis-api --resource-group halis --sku B1 --runtime "PYTHON:3.12"
# DİKKAT (AA Terminal dersi): az webapp up uygulama ayarlarını HER SEFERİNDE
# siler — deploy'dan sonra ayarları yeniden kur:
az webapp config appsettings set --name halis-api --resource-group halis --settings \
  ANTHROPIC_API_KEY=sk-... \
  HALIS_WEBHOOK_TOKEN=$(openssl rand -hex 24) \
  HALIS_DB=/home/data/halis.db \
  SCM_DO_BUILD_DURING_DEPLOYMENT=true
az webapp config set --name halis-api --resource-group halis \
  --startup-file "uvicorn app.main:app --host 0.0.0.0 --port 8000"
```

App Service'te `/home` kalıcıdır → `HALIS_DB=/home/data/halis.db` şart
(aksi halde her yeniden başlatmada kota/premium tablosu sıfırlanır).

## Seçenek B — Docker (herhangi bir VPS / Container Apps)

```bash
cd backend
docker build -t halis-api .
docker run -d -p 8000:8000 \
  -v halis-data:/data \
  -e ANTHROPIC_API_KEY=sk-... \
  -e HALIS_WEBHOOK_TOKEN=... \
  halis-api
```

## Deploy sonrası doğrulama

```bash
curl https://.../health                      # {"status":"ok","model":"claude-haiku-4-5"}
curl -H "X-Device-Id: test-device-0001" https://.../v1/quota
# → {"premium":false,"free_quota":10,"used":0,"remaining":10}
```

RevenueCat panelinde: Integrations → Webhooks → URL `https://.../v1/revenuecat-webhook`,
Authorization header = `HALIS_WEBHOOK_TOKEN` değeri.

Uygulama derlemesi: `flutter build ... --dart-define=HALIS_API_URL=https://...`
(anahtar yoksa uygulama backend'siz çalışmaya devam eder).
