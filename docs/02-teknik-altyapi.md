# Halis — Teknik Altyapı Araştırması (Temmuz 2026)

## Veri katmanı

### Open Food Facts (OFF) — ürün/barkod omurgası
- ~3-4M ürün, ücretsiz API: `https://world.openfoodfacts.org/api/v2/product/{barkod}.json` (özel User-Agent zorunlu; makul kullanımda rate limit yok).
- Resmi Flutter SDK: `openfoodfacts` (pub.dev).
- Ülke kapsamı: ABD ~862K, Almanya ~390K ürün (güçlü); **Türkiye ~8K, Endonezya ~7,5K (ÇOK zayıf)** → Türkiye kapsaması bizim dolduracağımız alan; kullanıcı katkısıyla (tarama sırasında fotoğraf yükletme) hem OFF'a hem kendi DB'mize veri toplarız.
- İçerik analizi API'dan hazır dönüyor: normalize içerik listesi, E-kodları, alerjenler, **vegan/vejetaryen analizi (yes/no/maybe)** → dolaylı helal sinyali (vegan=yes → jelatin/domuz riski yok).
- `en:halal` etiketi var (üretici logosu bazlı) ama içerik-bazlı otomatik helal analizi YOK — bizim katma değerimiz tam burası.

### ⚠️ ODbL lisans kritiği
- OFF verisi ticari kullanıma açık ama **share-alike**: OFF verisini kendi veritabanınla BİRLEŞTİRİRSEN türev DB'yi de ODbL ile açmak zorundasın.
- **Mimari karar:** Helal sınıflandırma veritabanımız (E-kod tablosu, hüküm motoru) OFF'tan AYRI tutulacak; OFF'a canlı API sorgusu atılacak, veriler runtime'da yan yana gösterilecek — DB birleştirme yok. Uygulamada OFF'a atıf verilecek.

### E-kodu helal sınıflandırması — ELLE DERLENECEK (çekirdek varlığımız)
- Hazır açık veritabanı YOK; web sayfası formatında kaynaklar var (HalalCodeCheck, HalalSpy, Halal Seeker) + Türkçe akademik makaleler + Diyanet fetvaları.
- Sınıflandırma modeli: az sayıda "varsayılan haram" (domuz jelatini kaynaklı E441 vb.) + geniş "mushbooh/kaynağa bağlı" listesi (E120 koşnil, E471 mono-digliserit, E904 şellak, E542, E631/E627...).
- **Mezhep farkları gerçek ve ürünleşebilir:**
  - İstihale (dönüşüm): Hanefi/Maliki kabul eder → bazı alimlerce jelatin bile helal olabilir; Şafii/Hanbeli "necis daima necis".
  - Diyanet: "hüküm E koduyla değil, maddenin kaynağıyla verilir"; E120 böcek kaynaklı → haram; jelatin domuz/gayr-i mezbuh ise haram. Fetvalar HTML sayfa, API yok.
- Bu tablo bizim savunulabilir varlığımız (moat): Diyanet + JAKIM + HMC kaynaklı, mezhep boyutlu, gerekçeli JSON tablosu.

### Sertifika veritabanları
- **Hiçbir resmi kuruluşun (JAKIM, BPJPH, IFANCA, HFSAA, HMC, TSE, GİMDES) açık geliştirici API'sı yok.** Hepsi web portalı / PDF / e-Devlet.
- JAKIM portal girişsiz sorgulanabiliyor; BPJPH arama endpoint'i URL parametreli; GİMDES Excel/PDF listesi yayınlıyor.
- Strateji: v1'de sertifika sorgusu YOK (scraping bakım yükü); v2'de Türkiye için GİMDES/TSE listelerini periyodik manuel senkron.

## Uygulama katmanı

### Barkod tarama — ücretsiz, on-device
- Flutter: **mobile_scanner** (kamera+dekode tek pakette, Android'de CameraX+ML Kit bundled, iOS'ta AVFoundation) — açık kaynak, kota yok.
- EAN-13/EAN-8/UPC (gıda barkodları) tam destekli.

### İçindekiler etiketi OCR — ücretsiz, on-device
- **ML Kit Text Recognition v2: tamamen ücretsiz, limitsiz, on-device.** Türkçe (Latin) kapsamda.

### LLM analiz maliyeti (istek başına ~800 girdi + ~500 çıktı token)
| Model | İstek başına | 1.000 istek |
|---|---|---|
| Claude Haiku 4.5 | ~$0,0033 | ~$3,30 |
| GPT-4o-mini | ~$0,00042 | ~$0,42 |
- Prompt caching (Claude): sabit E-kod tablosu + kurallar sistem prompt'u cache'lenirse girdi ~%90 indirimli.
- **Maliyet zırhı:** Barkod OFF'ta eşleşirse LLM'e hiç gidilmez (kural motoru yerel çalışır); LLM yalnız OCR fallback'te → istek hacmi %10-30'a düşer. Günde 10K taramada aylık maliyet ~$100-300 bandında tutulabilir.

## Hazır halal API'sı var mı?
- Barkod tabanlı, kurumsal, dokümante bir halal-check API pazarda YOK (tek bulunan: RapidAPI'de dar kapsamlı E-kod sorgu API'sı).
- → İleride B2B gelir kapısı: Halis API'sini market zincirlerine/e-ticarete satmak.

## Yasal/dini sorumluluk (disclaimer pratiği)
Sektör standardı (Scan Halal, HalalCodeCheck, ScanToHalal terms'lerinden):
1. "Dini hüküm değil, bilgilendirme" konumlandırması
2. As-is / garanti reddi
3. "Şüphede üreticiye/sertifika kuruluşuna danışın" yönlendirmesi
4. Karar ve sonuçları kullanıcıya aittir beyanı
5. Veri kaynaklarının güncel olmayabileceği uyarısı
→ Onboarding'de tek ekranlık net beyan + her sonuç kartında "kaynak ve gerekçe" gösterimi (güven = ürün).
