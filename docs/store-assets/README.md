# Mağaza görselleri

`ios-6.9/` — iPhone 17 Pro Max simülatörü, 1320×2868 (App Store 6,9" zorunlu boy;
Play Store de kabul eder). docs/04'teki planın 6 ekranı. Üstlerine 6 dilde tek
cümlelik pazarlama bandı eklenecek (docs/04 → ekran görüntüsü planı).

Eksik: "tarama anı" (kamera overlay) karesi — simülatörde kamera yok, gerçek
cihazdan alınacak.

## Yeniden üretme

```bash
cd app
# 1) ML Kit pod'ları arm64 simülatör dilimi içermiyor → iOS 26 simülatöründe
#    uygulama başlamaz. GEÇİCİ olarak (COMMIT ETME):
#    - pubspec.yaml: google_mlkit_text_recognition satırını yoruma al
#    - lib/services/ocr_service.dart: extractText gövdesini `async => '';` yap
flutter pub get
# 2) Testi sür (temiz kota için önce uygulamayı kaldır):
xcrun simctl uninstall <UDID> com.halis.halisApp
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart -d <UDID>
# 3) build/screenshots/ → docs/store-assets/ios-6.9/
# 4) Geri al: git checkout -- pubspec.yaml pubspec.lock ios/Podfile.lock \
#      ios/Runner.xcodeproj/project.pbxproj lib/services/ocr_service.dart
#    flutter pub get && (cd ios && pod install)
```

Testteki tuzaklar (çözüldü, bilgi için): `pageBack()` TR yerelde tooltip
bulamaz → `find.byType(BackButton)`; push edilen ekranın altında ana ekran
ağaçta kaldığından finder'lar `hitTestable()` ile daraltılır.
