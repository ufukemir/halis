import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Diyet/alerjen katmanı: helal hükmünün YANINA (asla yerine değil) kullanıcı
/// seçimli uyarılar ekler — gluten, laktoz, vegan vb. "Ailenin gıda bekçisi"
/// konumlanmasının temeli. Veri kaynağı: OFF `allergens_tags` +
/// `ingredients_analysis_tags`; uyarılar bilgilendirmedir, hüküm rengini
/// etkilemez.
class DietService {
  static const _key = 'diet_sensitivities_v1';

  /// Desteklenen hassasiyetler → OFF alerjen etiketi. OFF alerjen
  /// taksonomisinin tamamı (2026-08 itibarıyla 26 etiket; domuz hariç —
  /// hüküm motoru domuzu her profilde zaten işaretler, alerjen kutusu
  /// kafa karıştırır). vegan/vegetarian/palm_oil özel: analiz
  /// etiketlerinden okunur.
  static const allergenTagByKey = {
    // AB 1169/2011 zorunlu 14'lüsü.
    'gluten': 'en:gluten',
    'milk': 'en:milk',
    'eggs': 'en:eggs',
    'nuts': 'en:nuts',
    'peanuts': 'en:peanuts',
    'soy': 'en:soybeans',
    'sesame': 'en:sesame-seeds',
    'fish': 'en:fish',
    'crustaceans': 'en:crustaceans',
    'molluscs': 'en:molluscs',
    'celery': 'en:celery',
    'mustard': 'en:mustard',
    'sulphites': 'en:sulphur-dioxide-and-sulphites',
    'lupin': 'en:lupin',
    // Bölgesel/ek alerjenler (Japonya zorunlu listesi + OFF'taki diğerleri).
    'beef': 'en:beef',
    'chicken': 'en:chicken',
    'gelatin': 'en:gelatin',
    'apple': 'en:apple',
    'banana': 'en:banana',
    'kiwi': 'en:kiwi',
    'orange': 'en:orange',
    'peach': 'en:peach',
    'matsutake': 'en:matsutake',
    'yamaimo': 'en:yamaimo',
    'red_caviar': 'en:red-caviar',
  };

  /// AB zorunlu 14'lüsü — seçim ekranında ilk bölüm.
  static const euAllergenKeys = [
    'gluten', 'milk', 'eggs', 'nuts', 'peanuts', 'soy', 'sesame', 'fish',
    'crustaceans', 'molluscs', 'celery', 'mustard', 'sulphites', 'lupin',
  ];

  /// Bölgesel/ek alerjenler — ikinci bölüm.
  static List<String> get regionalAllergenKeys =>
      allergenTagByKey.keys.where((k) => !euAllergenKeys.contains(k)).toList();

  static const dietKeys = ['vegan', 'vegetarian', 'palm_oil'];
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
    List<String> tracesTags = const [],
    String? veganStatus,
    String? vegetarianStatus,
    String? palmOilStatus,
  }) {
    final warnings = <String>[];
    for (final entry in allergenTagByKey.entries) {
      if (!selectedKeys.contains(entry.key)) continue;
      if (allergenTags.contains(entry.value)) {
        warnings.add(entry.key);
      } else if (tracesTags.contains(entry.value)) {
        // "İçerebilir" beyanı: içerik listesinde yok ama üretici iz miktarda
        // bulaşma uyarısı vermiş — alerjik kullanıcı için ayrı etiketle uyar.
        warnings.add('${entry.key}:trace');
      }
    }
    if (selectedKeys.contains('vegan') && (veganStatus == 'no' || veganStatus == 'maybe')) {
      warnings.add('vegan');
    }
    if (selectedKeys.contains('vegetarian') &&
        (vegetarianStatus == 'no' || vegetarianStatus == 'maybe')) {
      warnings.add('vegetarian');
    }
    if (selectedKeys.contains('palm_oil') &&
        (palmOilStatus == 'yes' || palmOilStatus == 'maybe')) {
      warnings.add('palm_oil');
    }
    return warnings;
  }

  /// Ürün üstünden kısayol.
  Future<List<String>> warningsForProduct(OffProduct p) async => warningsFor(
        selectedKeys: await selected(),
        allergenTags: p.allergenTags,
        tracesTags: p.tracesTags,
        veganStatus: p.veganStatus,
        vegetarianStatus: p.vegetarianStatus,
        palmOilStatus: p.palmOilStatus,
      );
}
