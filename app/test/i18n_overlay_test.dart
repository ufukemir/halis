import 'package:flutter_test/flutter_test.dart';
import 'package:halis_app/l10n/overlay.dart';
import 'package:halis_app/l10n/strings.dart';

/// "Diller düzgün çalışsın" bekçisi: 11 overlay dilinin anahtar kümeleri
/// birebir aynı olmalı (bir dilde çevrilen dizge diğerlerinde unutulamaz),
/// hiçbir çeviri boş olamaz ve overlay gerçekten devrede olmalı.
void main() {
  const referenceLang = 'es';

  group('overlay tutarlılığı', () {
    test('S.supported ile overlay + çekirdek diller birebir örtüşür', () {
      const core = {'tr', 'en', 'de', 'fr', 'ar', 'id'};
      expect(
        S.supported.toSet(),
        core.union(kOverlayTranslations.keys.toSet()),
      );
      expect(S.supported.length, 17);
    });

    test('tüm overlay dilleri aynı anahtar kümesine sahip', () {
      final reference = kOverlayTranslations[referenceLang]!.keys.toSet();
      expect(reference, isNotEmpty);
      for (final entry in kOverlayTranslations.entries) {
        final keys = entry.value.keys.toSet();
        expect(keys.difference(reference), isEmpty,
            reason: '${entry.key}: fazla anahtar');
        expect(reference.difference(keys), isEmpty,
            reason: '${entry.key}: eksik anahtar');
      }
    });

    test('hiçbir çeviri boş değil', () {
      for (final entry in kOverlayTranslations.entries) {
        for (final kv in entry.value.entries) {
          expect(kv.value.trim(), isNotEmpty,
              reason: '${entry.key} → "${kv.key}"');
        }
      }
    });

    test('yer tutucular çevirilerde korunmuş ({n}, {total}, {price}...)', () {
      final placeholderRe = RegExp(r'\{[a-z]+\}');
      final reference = kOverlayTranslations[referenceLang]!;
      for (final key in reference.keys) {
        final expected =
            placeholderRe.allMatches(key).map((m) => m.group(0)).toSet();
        if (expected.isEmpty) continue;
        for (final entry in kOverlayTranslations.entries) {
          final got = placeholderRe
              .allMatches(entry.value[key]!)
              .map((m) => m.group(0))
              .toSet();
          expect(got, expected, reason: '${entry.key} → "$key"');
        }
      }
    });

    test('her supported dilde temel dizgeler dolu ve overlay devrede', () {
      for (final lang in S.supported) {
        final s = S(lang);
        expect(s.scanBarcode.trim(), isNotEmpty, reason: lang);
        expect(s.settingsTitle.trim(), isNotEmpty, reason: lang);
        expect(s.verdictTitle, isNotNull, reason: lang);
      }
      // Overlay gerçekten çeviriyor mu? (EN'e düşmüyor mu?)
      expect(S('ru').settingsTitle, 'Настройки');
      expect(S('ur').settingsTitle, isNot('Settings'));
      expect(S('bn').settingsTitle, isNot('Settings'));
    });
  });
}
