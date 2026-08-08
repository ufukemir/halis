import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/services/diet_service.dart';

void main() {
  group('diyet/alerjen uyarıları (saf mantık)', () {
    test('seçili alerjen üründe varsa uyarı, seçili değilse yok', () {
      final w = DietService.warningsFor(
        selectedKeys: {'gluten', 'milk'},
        allergenTags: ['en:gluten', 'en:eggs'],
      );
      expect(w, ['gluten']); // eggs seçili değil, milk üründe yok
    });

    test('vegan seçiliyken non-vegan ve maybe-vegan uyarır, yes uyarmaz', () {
      expect(
          DietService.warningsFor(selectedKeys: {'vegan'}, allergenTags: [], veganStatus: 'no'),
          ['vegan']);
      expect(
          DietService.warningsFor(selectedKeys: {'vegan'}, allergenTags: [], veganStatus: 'maybe'),
          ['vegan']);
      expect(
          DietService.warningsFor(selectedKeys: {'vegan'}, allergenTags: [], veganStatus: 'yes'),
          isEmpty);
    });

    test('hiç seçim yoksa hiç uyarı yok', () {
      final w = DietService.warningsFor(
        selectedKeys: {},
        allergenTags: ['en:gluten', 'en:milk'],
        veganStatus: 'no',
      );
      expect(w, isEmpty);
    });

    test('tüm anahtarların OFF etiketi tanımlı', () {
      for (final key in DietService.allergenTagByKey.keys) {
        expect(DietService.allergenTagByKey[key], startsWith('en:'), reason: key);
      }
    });
  });
}
