# Halis — Platform ve Cihaz Kapsamı (dürüst tablo)

Güncelleme: 2026-08-10. Soru: "Her telefonda, her tablette, her işletim sisteminde
çalışıyor mu; mağazadan geri gelir mi?"

## Destekleniyor ✅

| Platform | Kapsam | Not |
|---|---|---|
| **iPhone** | iOS 15.5+ | Flutter tabanı; 15.5 = 2015 sonrası neredeyse tüm iPhone'lar (6s dahil) |
| **iPad** | iPadOS 15.5+ | Proje zaten iPhone+iPad (`TARGETED_DEVICE_FAMILY 1,2`), 4 yön tanımlı, tam ekran modu beyan edildi; ana ekran içerik genişliği 640dp ile sınırlandı (yayılma yok) |
| **Android telefon** | Android 7.0+ (minSdk 24, 2016+) | Pazarın ~%98'i; RevenueCat'in alt sınırı |
| **Android tablet** | Android 7.0+ | Manifest'te ekran kısıtı yok; kamera `required=false` beyan edildi → kamerasız cihazlara da açılır (elle barkod + arama + ansiklopedi çalışır) |
| **ChromeOS** | Android uygulaması olarak | Kamera opsiyonel beyanı sayesinde listelenir |
| **Huawei (EMUI, Çin dışı tüm modeller)** | AppGallery APK | GMS bağımlılığı yok (ML Kit gömülü); RevenueCat çalışmaz → v1 ÜCRETSİZ (docs/04 kararı). Gerçek Huawei cihazda smoke test yapılmadı — yayın öncesi tek eksik |

## Kapsam dışı (bilinçli) ❌

| Platform | Neden |
|---|---|
| **HarmonyOS NEXT** (2024+ Çin içi Huawei) | Android çalışma zamanı yok; Flutter resmî desteklemiyor (topluluk portu deneysel). Çin dışında satılan Huawei'ler EMUI/Android'dir → AppGallery APK'sı ile kapsanır. Çin pazarı zaten ayrı lisans/ICP meselesi. |
| **Web / Windows / macOS** | Kamera barkod tarama, gömülü ML Kit OCR ve RevenueCat bu platformlarda yok; uygulamanın çekirdek akışı telefona bağlı. Talep doğarsa ayrı proje. |
| **iOS < 15.5 / Android < 7.0** | Eklenti alt sınırları (RevenueCat, mobile_scanner). Etkilenen cihaz oranı ~%1-2. |

## "Mağazadan geri gelmesin" kontrol listesi

Bu turda kapatılanlar:
- [x] `ITSAppUsesNonExemptEncryption = false` (yalnız HTTPS) — her TestFlight/yayın
      yüklemesindeki export-compliance takılmasını bitirir
- [x] `UIRequiresFullScreen = true` — iPad çoklu-pencere/yeniden boyutlandırma
      zorunluluklarının kapsamı dışında kalır (yaygın red sebebi)
- [x] Kamera/galeri izin metinleri iki dilli (EN+TR) — incelemeci İngilizce görür
- [x] Android `uses-feature camera required=false` — Play'in cihaz eleme filtresine takılmaz
- [x] Tablet düzeni: ana ekran 640dp sınırlı; diğer ekranlar liste tabanlı (tablet güvenli)

Reklam (AdMob) notları:
- Ücretsiz katman ödüllü reklamla çalışır (1 reklam = 1 tarama); reklam
  yüklenemezse tarama ÜCRETSİZ devam eder (fail-open) — çevrimdışı/incelemede
  uygulama asla kilitlenmez.
- Şu an Google'ın resmî TEST kimlikleri gömülü (gelir üretmez). Gerçek
  kimlikler: AndroidManifest `com.google.android.gms.ads.APPLICATION_ID`,
  Info.plist `GADApplicationIdentifier` + `--dart-define=ADMOB_REWARDED_ID_ANDROID/IOS`.
- Huawei (HMS, GMS'siz) cihazlarda AdMob reklam SUNMAZ → fail-open sayesinde
  AppGallery sürümünde taramalar reklamsız-ücretsiz kalır (v1 zaten ücretsizdi).

Yayın anına kalanlar (Ufuk):
- [ ] AdMob hesabı aç, gerçek uygulama+ödüllü reklam kimliklerini yukarıdaki
      üç noktaya koy (test kimliğiyle YAYINLANMAZ — politika ihlali)
- [ ] AB/İngiltere için UMP onay akışı (google_mobile_ads ConsentInformation)
      — GDPR zorunluluğu; kişiselleştirilmemiş istek tek başına yeterli değil
- [ ] Data Safety/App Privacy beyanlarına reklam verilerini ekle (docs/04 notu)
- [ ] **iPad ekran görüntüleri (13")** — cihaz ailesi iPad'i içerdiği için App Store
      ZORUNLU tutar; iPad simülatörü zaten kurulu, tarif store-assets/README
- [ ] Play **Data Safety** formu — docs/04'teki beyanlarla birebir doldur
- [ ] App Store inceleme notu: "Sonuçlar dini hüküm değildir" disclaimer'ının yerini yaz
      (madde 1.1 din içeriği sorusuna hazır cevap) + incelemeci için elle barkod girişi
      alanını not et (kamerasız test edebilsinler; örnek barkod: 3017620422003)
- [ ] AppGallery: bir Huawei cihazda 10 dakikalık smoke test (tarama + etiket + dil değiştir)
- [ ] Play hedef API düzeyi uyarısı çıkarsa `flutter upgrade` sonrası yeniden AAB al
