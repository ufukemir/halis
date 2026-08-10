import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tarama kredisi (1 reklam = 1 tarama)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('ilk kurulumda hoş geldin kredisi verilir', () async {
      expect(await ScanCreditService().balance(), ScanCreditService.welcomeCredits);
    });

    test('consume krediyi düşer, sıfırda false döner', () async {
      final svc = ScanCreditService();
      final start = await svc.balance();
      for (var i = 0; i < start; i++) {
        expect(await svc.consume(), isTrue);
      }
      expect(await svc.balance(), 0);
      expect(await svc.consume(), isFalse); // kredi yok → kapı reklama yönlendirir
    });

    test('grant kredi ekler ve tekrar taranabilir', () async {
      final svc = ScanCreditService();
      while (await svc.consume()) {}
      await svc.grant();
      expect(await svc.balance(), 1);
      expect(await svc.consume(), isTrue);
      expect(await svc.consume(), isFalse);
    });

    test('hoş geldin paketi yalnız bir kez verilir (bakiye 0 yeniden dolmaz)', () async {
      final svc = ScanCreditService();
      while (await svc.consume()) {}
      expect(await svc.balance(), 0); // seed tekrarlanmamalı
    });
  });
}
