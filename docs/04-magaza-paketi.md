# Halis — Mağaza Paketi (App Store + Google Play)

## Kimlik

| Alan | Değer |
|---|---|
| Uygulama adı | **Halis** |
| Mağaza başlığı | Halis — Helal Gıda Tarayıcı / Halal Food Scanner |
| Paket (Android) | `com.halis.app` |
| Bundle ID (iOS) | `com.halis.halisApp` (Xcode'da görünen; istenirse App Store Connect'te `com.halis.app` olarak yeniden oluşturulabilir — ilk yüklemeden ÖNCE kararlaştır) |
| Sürüm | 1.0.0 (build 1) |
| Kategori | Yemek & İçecek (Food & Drink) / Sağlık |
| Yaş | 4+ |
| Fiyat | Ücretsiz (v1.1'de abonelik: sınırsız AI analiz ~29,99 $/yıl) |
| Diller | TR, EN, DE, FR, AR, ID |

## Mağaza açıklamaları

### Türkçe — kısa açıklama (80 kr)
> Barkodu tara, içindekini bil. Helal hassasiyetiyle içerik analizi.

### Türkçe — uzun açıklama
> **Markette kararsız kalma. Barkodu tarat, saniyeler içinde bil.**
>
> Halis, ürünlerin içindekiler listesini helal hassasiyetiyle analiz eden reklamsız bir bilgilendirme aracıdır.
>
> ✓ **Barkod tarama** — milyonlarca ürünün içerik verisine anında erişim
> ✓ **Etiket fotoğrafı analizi** — ürün veritabanında yoksa etiketi çek, cihaz üzerinde okunsun
> ✓ **Gerekçeli sonuç** — sadece renk değil: hangi madde, neden şüpheli, hangi kaynağa göre
> ✓ **Hassasiyet profili** — Temkinli, Genişlik veya Diyanet yaklaşımına göre değerlendirme
> ✓ **304 katkı maddesi (E-kodu) veritabanı** — mezhep farkları ve gerekçelerle; katkıyı kodla değil adıyla yazan etiketleri de tanır
> ✓ **6 dil, 6 etiket dili** — Türkçe, İngilizce, Almanca, Fransızca, Arapça, Endonezyaca etiketleri tanır
> ✓ **Reklamsız** — asla reklam göstermeyiz, asla marka parası almayız
>
> **Dürüstlük ilkemiz:** Emin olamadığımızda "şüpheli" deriz; asla tahminle "helal" demeyiz. Sonuçlarımız dini hüküm değil, içerik verilerine dayalı bilgilendirmedir.
>
> Ürün verisi: Open Food Facts (ODbL).

### English — subtitle (30 ch, App Store)
> Halal ingredient scanner

### English — description
> **Stop guessing at the supermarket. Scan the barcode, know in seconds.**
>
> Halis is an ad-free informational tool that analyzes product ingredients with halal sensitivity.
>
> ✓ **Barcode scanning** — instant access to ingredient data for millions of products
> ✓ **Label photo analysis** — product not in the database? Snap the label; it's read on your device
> ✓ **Explained results** — not just a color: which ingredient, why doubtful, per which source
> ✓ **Sensitivity profiles** — Cautious, Lenient, or Diyanet methodology
> ✓ **304 additive (E-number) database** — with school-of-thought differences and reasoning; recognizes additives written by name, not just by code
> ✓ **6 languages** — recognizes labels in Turkish, English, German, French, Arabic, Indonesian
> ✓ **Ad-free** — we never show ads and never take money from brands
>
> **Our honesty principle:** when we're not sure, we say "doubtful" — we never guess "halal". Results are informational, based on ingredient data, not religious rulings.
>
> Product data: Open Food Facts (ODbL).

### Diğer diller
DE/FR/AR/ID açıklamaları EN metninden çevrilecek (lansman sonrası ilk hafta; App Store Connect + Play Console yerelleştirme alanlarına).

## Anahtar kelimeler (ASO)

- **TR:** helal, helal mi, e kodu, katkı maddesi, barkod, içindekiler, jelatin, E471, helal gıda, gıda kontrol
- **EN:** halal, halal check, halal scanner, e number, additives, is it halal, ingredients, halal food, barcode scanner, gelatin
- **DE:** halal, halal check, e-nummern, zusatzstoffe, zutaten scanner
- **FR:** halal, vérificateur halal, additifs, e-numéros, scanner ingrédients
- **AR:** حلال، فحص حلال، مكونات، إضافات
- **ID:** halal, cek halal, komposisi, pemindai halal, bahan tambahan

## Ekran görüntüsü planı (6,7"/6,5" + 5,5" iOS; telefon+7"tablet Android)

1. Ana ekran — "Barkodu tara, içindekini bil" + profil seçici
2. Tarama anı — çerçeve overlay
3. Yeşil sonuç kartı (gerekçeli, güven yüzdeli)
4. Turuncu "Şüpheli" kartı — E471 tespiti açık halde (farklılaştırıcı ekran!)
5. Etiket fotoğrafı analizi ekranı
6. Onboarding/dürüstlük ilkesi ekranı
Her görüntünün üstüne tek cümlelik pazarlama bandı (6 dilde).

## Gizlilik (Data Safety / App Privacy)

- Hesap yok, tarama geçmişi yalnız cihazda.
- Ağ istekleri:
  - Open Food Facts: barkod sorgusu (barkod dışında veri gitmez).
  - Halis backend (yapılandırıldıysa): etiket METNİ + kota için anonim cihaz
    kimliği (`X-Device-Id`). Fotoğraf backend'imize hiçbir zaman gitmez.
  - OFF katkı akışı (yalnız kullanıcı isterse): ürün bulunamadığında etiket
    fotoğrafı, ODbL uyarılı açık onay diyaloğundan sonra Open Food Facts'e
    herkese açık yüklenir. Onaysız yükleme yoktur.
- Üçüncü taraf reklam/izleme SDK'sı YOK. Abonelik için RevenueCat SDK'sı
  (satın alma doğrulaması; anonim uygulama kullanıcı kimliği).
- Gerekli beyanlar (backend + RevenueCat aktifken "Data Not Collected" ARTIK
  DOĞRU DEĞİL — yanlış beyan ret/kaldırma sebebi):
  - iOS App Privacy: "Identifiers → Device ID" (App Functionality, not linked
    to identity, no tracking) + "Purchases" (RevenueCat).
  - Play Data Safety: "Device or other IDs" (App functionality) + "Purchase
    history" (RevenueCat); paylaşım yok, tracking yok.
  - v1 backend'siz ve mağazasız çıkarsa bu beyanlar sadeleşir → "No data
    collected" yeniden geçerli olur (OFF katkısı kullanıcı eylemidir,
    yine de fotoğraf yüklemesini politika metninde belirt).
- Gizlilik politikası sayfası: halis.app/privacy (alan adı alınınca; taslak aşağıda).

### Gizlilik politikası taslağı (halis.app/privacy)
> Halis'te hesap açılmaz, kimliğinizle ilişkilendirilebilir kişisel veri toplanmaz. Tarama geçmişiniz yalnızca cihazınızda saklanır ve bize gönderilmez. Barkod taramalarında yalnızca barkod numarası Open Food Facts servisine iletilir. Etiket fotoğrafları cihazınızda işlenir ve sunucularımıza yüklenmez; yapay zekâ ile metin düzeltme açıksa yalnızca etiketin METNİ, aylık kota takibi için rastgele üretilmiş anonim bir cihaz kimliğiyle birlikte sunucumuza iletilir. Bulunamayan bir ürünün etiket fotoğrafını, dilerseniz ve ancak açık onayınızla, açık gıda veritabanı Open Food Facts'e (ODbL lisansı, herkese açık) katkı olarak gönderebilirsiniz. Abonelik satın alımları RevenueCat altyapısıyla, anonim bir kimlik üzerinden doğrulanır. Reklam ve izleme SDK'sı kullanmayız, verilerinizi kimseyle paylaşmayız ve satmayız. Sorular: destek@halis.app

## Huawei AppGallery (3. mağaza)

Durum (2026-08-08): teknik engel görünmüyor, hesap + cihaz doğrulaması bekliyor.

- **GMS bağımlılığı YOK (teoride):** ML Kit OCR ve mobile_scanner barkod,
  *gömülü model* sürümlerini kullanır (Play Services gerektirmez); Firebase,
  harita, push yok. → APK, HMS'li (GMS'siz) Huawei cihazda çalışmalı.
  ⚠️ Gerçek Huawei cihazında DOĞRULANMADI — yayın öncesi şart.
- **Premium satılamaz:** RevenueCat yalnız Play Billing/App Store bilir.
  Uygulama mağazasız modda zarifçe ücretsiz katmana düşer → AppGallery v1
  **ücretsiz sürüm** olarak çıkar; Huawei IAP entegrasyonu talep görürse eklenir.
- **Paket:** `flutter build apk --release --split-per-abi` → arm64-v8a APK
  (39 MB) yüklenir (AppGallery AAB de kabul eder).
- **Gerekenler (Ufuk):** AppGallery Connect geliştirici hesabı (bireysel
  ücretsiz, kimlik doğrulamalı), mağaza görselleri (mevcutlar yeniden
  kullanılır), gizlilik politikası URL'si (halis.app/privacy).

## Yükleme öncesi kontrol listesi

- [ ] Apple Developer hesabı (99 $/yıl) — **Ufuk**
- [ ] Google Play Console hesabı (25 $ tek sefer) — **Ufuk**
- [ ] halis.app alan adı + privacy sayfası — **Ufuk**
- [ ] Bundle ID kararı (`com.halis.app` önerilir; iOS projesinde güncelle)
- [ ] Ekran görüntüleri (plan yukarıda; simülatörden alınabilir)
- [x] OFF User-Agent yayın değerinde: `Halis/1.0.0 (halal food scanner; https://halis.app; destek@halis.app)` (`app/lib/services/off_config.dart`)
- [ ] RevenueCat panel: ürün/teklif + webhook URL'si (`/v1/revenuecat-webhook`) + `HALIS_WEBHOOK_TOKEN`
- [ ] Backend deploy kararı: v1'de backend'li mi backend'siz mi? (backend/DEPLOY.md)
- Not: `data/` dosyalarının dini danışman incelemesi yayın önkoşulu DEĞİLDİR
  (Ufuk, 2026-08-07); istenirse sonradan güven/pazarlama unsuru olarak yaptırılır.
- [x] AAB: `flutter build appbundle --release` — 2026-08-08'de doğrulandı,
      74 MB imzalı paket üretildi (imzalama ~/halis-keys ile otomatik)
- [ ] AppGallery Connect hesabı + Huawei cihaz testi (yukarıdaki bölüm) — **Ufuk**
- [ ] iOS: `flutter build ipa` + Transporter/Xcode ile yükleme
- [ ] ⚠️ `~/halis-keys/` YEDEKLE (kaybolursa Play'de güncelleme yapılamaz!)
