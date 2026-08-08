import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Diyet/alerjen katmanı: helal hükmünün YANINA (asla yerine değil) kullanıcı
/// seçimli uyarılar ekler — gluten, laktoz, vegan vb. "Ailenin gıda bekçisi"
/// konumlanmasının temeli. Veri kaynağı: OFF `allergens_tags` +
/// `ingredients_analysis_tags`; uyarılar bilgilendirmedir, hüküm rengini
/// etkilemez.
class DietService {
  static const _key = 'diet_sensitivities_v1';

  /// Desteklenen hassasiyetler → OFF alerjen etiketi.
  /// vegan/vegetarian özel: analiz etiketlerinden okunur.
  static const allergenTagByKey = {
    'gluten': 'en:gluten',
    'milk': 'en:milk',
    'eggs': 'en:eggs',
    'nuts': 'en:nuts',
    'peanuts': 'en:peanuts',
    'soy': 'en:soybeans',
    'sesame': 'en:sesame-seeds',
    'fish': 'en:fish',
  };
  static const dietKeys = ['vegan', 'vegetarian'];
  static List<String> get allKeys => [...allergenTagByKey.keys, ...dietKeys];

  Future<Set<String>> selected() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> setSelected(Set<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, keys.toList()..sort());
  }

  /// Ürün için tetiklenen uyarı anahtarları (seçili hassasiyetlerle kesişim).
  /// Saf fonksiyon — test edilebilir.
  static List<String> warningsFor({
    required Set<String> selectedKeys,
    required List<String> allergenTags,
    String? veganStatus,
    String? vegetarianStatus,
  }) {
    final warnings = <String>[];
    for (final entry in allergenTagByKey.entries) {
      if (selectedKeys.contains(entry.key) && allergenTags.contains(entry.value)) {
        warnings.add(entry.key);
      }
    }
    if (selectedKeys.contains('vegan') && (veganStatus == 'no' || veganStatus == 'maybe')) {
      warnings.add('vegan');
    }
    if (selectedKeys.contains('vegetarian') &&
        (vegetarianStatus == 'no' || vegetarianStatus == 'maybe')) {
      warnings.add('vegetarian');
    }
    return warnings;
  }

  /// Ürün üstünden kısayol.
  Future<List<String>> warningsForProduct(OffProduct p) async => warningsFor(
        selectedKeys: await selected(),
        allergenTags: p.allergenTags,
        veganStatus: p.veganStatus,
        vegetarianStatus: p.vegetarianStatus,
      );
}
