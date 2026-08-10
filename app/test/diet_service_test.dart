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

    test('AB 1169/2011 zorunlu 14 alerjenin tamamı + bölgesel ek liste kapsanır', () {
      expect(DietService.euAllergenKeys.length, 14);
      expect(
        DietService.euAllergenKeys,
        containsAll(['crustaceans', 'molluscs', 'celery', 'mustard', 'sulphites', 'lupin']),
      );
      // OFF taksonomisindeki ek alerjenler (domuz hariç — hüküm motoru işi).
      expect(DietService.allergenTagByKey.length, 25);
      expect(
        DietService.regionalAllergenKeys,
        containsAll(['beef', 'chicken', 'gelatin', 'kiwi', 'red_caviar']),
      );
    });

    test('yeni alerjenler tetiklenir (sülfit + hardal)', () {
      final w = DietService.warningsFor(
        selectedKeys: {'sulphites', 'mustard', 'lupin'},
        allergenTags: ['en:sulphur-dioxide-and-sulphites', 'en:mustard'],
      );
      expect(w, containsAll(['sulphites', 'mustard']));
      expect(w, isNot(contains('lupin')));
    });

    test('"içerebilir" (traces) beyanı ayrı iz etiketiyle uyarır', () {
      final w = DietService.warningsFor(
        selectedKeys: {'gluten', 'peanuts'},
        allergenTags: ['en:gluten'],
        tracesTags: ['en:peanuts'],
      );
      expect(w, containsAll(['gluten', 'peanuts:trace']));
    });

    test('alerjen hem içerikte hem izde ise içerik uyarısı kazanır (çift uyarı yok)', () {
      final w = DietService.warningsFor(
        selectedKeys: {'milk'},
        allergenTags: ['en:milk'],
        tracesTags: ['en:milk'],
      );
      expect(w, ['milk']);
    });

    test('palm yağı: yes/maybe uyarır, no/null uyarmaz', () {
      List<String> run(String? status) => DietService.warningsFor(
          selectedKeys: {'palm_oil'}, allergenTags: [], palmOilStatus: status);
      expect(run('yes'), ['palm_oil']);
      expect(run('maybe'), ['palm_oil']);
      expect(run('no'), isEmpty);
      expect(run(null), isEmpty);
    });
  });
}
