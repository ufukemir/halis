import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/normalize_api.dart';
import 'package:halis_app/services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('aylık AI analiz kotası', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('yeni ay: kota dolu, analiz serbest', () async {
      expect(await PremiumService.canAnalyzeLabel(), isTrue);
      expect(await PremiumService.usedLabelAnalyses(), 0);
      expect(await PremiumService.remainingLabelAnalyses(), PremiumService.freeLabelQuota);
    });

    test('her kayıt sayacı artırır, kota bitince analiz kapanır', () async {
      for (var i = 0; i < PremiumService.freeLabelQuota; i++) {
        expect(await PremiumService.canAnalyzeLabel(), isTrue);
        await PremiumService.recordLabelAnalysis();
      }
      expect(await PremiumService.usedLabelAnalyses(), PremiumService.freeLabelQuota);
      expect(await PremiumService.remainingLabelAnalyses(), 0);
      expect(await PremiumService.canAnalyzeLabel(), isFalse);
    });

    test('kalan hak hiçbir zaman negatife düşmez', () async {
      for (var i = 0; i < PremiumService.freeLabelQuota + 3; i++) {
        await PremiumService.recordLabelAnalysis();
      }
      expect(await PremiumService.remainingLabelAnalyses(), 0);
    });

    test('mağaza anahtarı tanımlı değilken premium=false ve mağaza kapalı', () async {
      expect(await PremiumService.isPremium(), isFalse);
      expect(PremiumService.storeConfigured, isFalse);
    });

    test('cihaz kimliği üretilir ve kararlıdır (mağazasız mod → local- öneki)', () async {
      final first = await PremiumService.deviceId();
      final second = await PremiumService.deviceId();
      expect(first, startsWith('local-'));
      expect(first.length, greaterThanOrEqualTo(8));
      expect(second, first);
    });
  });

  group('NormalizedLabel', () {
    test('backend yanıtını çözümler ve birleşik metin üretir', () {
      final n = NormalizedLabel.fromJson(const {
        'ingredients': ['şeker', 'bitkisel yağ', 'kakao'],
        'e_codes': ['E471', 'E322'],
        'animal_derived_terms': ['jelatin'],
        'alcohol_terms': [],
        'ocr_quality': 'good',
      });
      expect(n.ingredients, hasLength(3));
      expect(n.ocrQuality, 'good');
      expect(n.combinedText, 'şeker, bitkisel yağ, kakao, E471, E322, jelatin');
    });

    test('eksik alanlar boş kabul edilir', () {
      final n = NormalizedLabel.fromJson(const {});
      expect(n.ingredients, isEmpty);
      expect(n.eCodes, isEmpty);
      expect(n.ocrQuality, 'partial');
      expect(n.combinedText, isEmpty);
    });

    test('API adresi tanımlı değilken servis kapalıdır ve null döner', () async {
      expect(NormalizeApi.isConfigured, isFalse);
      expect(await NormalizeApi().normalize('şeker, jelatin'), isNull);
    });
  });
}
