import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:halis_app/main.dart' as app;

/// Uçtan uca akış: onboarding → ana ekran → Nutella barkodu (canlı OFF sorgusu)
/// → sonuç kartı → etiket analizi (Fransızca haram örneği). Her adımda mağaza
/// ekran görüntüsü alınır (build/screenshots/).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Bulunamadı: $finder');
  }

  testWidgets('tam akış', (tester) async {
    await app.main();
    await tester.pump(const Duration(seconds: 2));

    // 1) Onboarding
    await pumpUntil(tester, find.byType(FilledButton));
    if (Platform.isAndroid) {
      // Android'de ekran görüntüsü öncesi zorunlu dönüşüm.
      await binding.convertFlutterSurfaceToImage();
      await tester.pump(const Duration(milliseconds: 300));
    }
    await binding.takeScreenshot('01-onboarding');
    await tester.tap(find.byType(FilledButton));
    await tester.pump(const Duration(seconds: 1));

    // 2) Ana ekran
    await pumpUntil(tester, find.byIcon(Icons.qr_code_scanner));
    await binding.takeScreenshot('02-ana-ekran');

    // 3) Elle barkod: Nutella → canlı OFF sorgusu → sonuç kartı
    await tester.enterText(find.byType(TextField).first, '3017620422003');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.search));
    await pumpUntil(tester, find.textContaining('Nutella'),
        timeout: const Duration(seconds: 40));
    await tester.pump(const Duration(seconds: 1));
    await binding.takeScreenshot('03-nutella-sonuc');

    // Geri dön
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));

    // 4) Etiket analizi: Fransızca domuz jelatini → kırmızı kart
    await pumpUntil(tester, find.byIcon(Icons.photo_camera));
    await tester.tap(find.byIcon(Icons.photo_camera).first);
    await tester.pump(const Duration(seconds: 1));
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(
        find.byType(TextField).first, 'sucre, sirop de glucose, gélatine de porc, arômes');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntil(tester, find.byIcon(Icons.cancel));
    await binding.takeScreenshot('04-etiket-haram');
  });
}
