/// Halis — temel modeller.
///
/// Hüküm sıralaması önem sırasına göredir: haram > mushbooh > halal.
/// `unknown` yalnız veri yetersizliğinde döner ve asla yeşil gösterilmez.
enum Verdict { halal, mushbooh, haram, unknown }

/// Kullanıcının seçtiği değerlendirme ölçüsü.
///
/// `musluman` ("Sadece Müslümanım") veride ayrı sütun değildir: beş mezhep
/// sütununun en ihtiyatlısı alınır — biri haram diyorsa haram gösterilir.
/// Mezhep bilmeyen/söylemek istemeyen herkesin güvenli varsayılanıdır.
enum Profile { musluman, hanefi, safii, maliki, hanbeli, caferi, diyanet }

/// Veride sütunu olan profiller (musluman bunlardan hesaplanır; diyanet
/// mezhep değil fetva mercii olduğundan ortak paydaya katılmaz).
const List<Profile> _madhhabs = [
  Profile.hanefi, Profile.safii, Profile.maliki, Profile.hanbeli, Profile.caferi,
];

extension ProfileKey on Profile {
  String get key => switch (this) {
        Profile.musluman => 'musluman',
        Profile.hanefi => 'hanefi',
        Profile.safii => 'safii',
        Profile.maliki => 'maliki',
        Profile.hanbeli => 'hanbeli',
        Profile.caferi => 'caferi',
        Profile.diyanet => 'diyanet',
      };

  String get labelTr => switch (this) {
        Profile.musluman => 'Sadece Müslümanım',
        Profile.hanefi => 'Hanefî',
        Profile.safii => 'Şafiî',
        Profile.maliki => 'Mâlikî',
        Profile.hanbeli => 'Hanbelî',
        Profile.caferi => 'Caferî',
        Profile.diyanet => 'Diyanet',
      };

  /// İhtiyat çizgisi: hafif şüpheliler (peynir altı suyu, laktoz vb.) bu
  /// profillerde hükmü etkiler, diğerlerinde bilgi notu olarak kalır.
  bool get ihtiyatli => switch (this) {
        Profile.musluman || Profile.safii || Profile.hanbeli || Profile.caferi => true,
        Profile.hanefi || Profile.maliki || Profile.diyanet => false,
      };

  static Profile? fromKey(String? key) {
    for (final p in Profile.values) {
      if (p.key == key) return p;
    }
    return null;
  }
}

Verdict verdictFromString(String s) => switch (s) {
      'halal' => Verdict.halal,
      'mushbooh' => Verdict.mushbooh,
      'haram' => Verdict.haram,
      _ => Verdict.unknown,
    };

/// E-kod tablosundaki tek kayıt.
class EcodeEntry {
  final String code;
  final String nameTr;
  final String nameEn;
  final String source;
  final Map<String, String> verdictByProfile;
  final String reasonTr;
  final String reasonEn;

  /// Etikette kod yerine yazılabilen isimler (tüm diller, küçük harf);
  /// yalnız sorunlu kodlarda doludur.
  final List<String> aliases;

  /// Alias eşleşmesini iptal eden kalıplar (ör. "bitkisel gliserin").
  final List<String> aliasExceptions;

  const EcodeEntry({
    required this.code,
    required this.nameTr,
    required this.nameEn,
    required this.source,
    required this.verdictByProfile,
    required this.reasonTr,
    required this.reasonEn,
    this.aliases = const [],
    this.aliasExceptions = const [],
  });

  factory EcodeEntry.fromJson(Map<String, dynamic> j) => EcodeEntry(
        code: (j['code'] as String).toUpperCase(),
        nameTr: j['name_tr'] as String,
        nameEn: j['name_en'] as String,
        source: j['source'] as String,
        verdictByProfile: Map<String, String>.from(j['verdict'] as Map),
        reasonTr: j['reason_tr'] as String,
        reasonEn: j['reason_en'] as String,
        aliases: List<String>.from(j['aliases'] as List? ?? []),
        aliasExceptions: List<String>.from(j['alias_exceptions'] as List? ?? []),
      );

  Verdict verdictFor(Profile p) {
    if (p == Profile.musluman) {
      // Ortak payda: mezhep sütunlarının en ihtiyatlısı.
      var worst = Verdict.halal;
      for (final m in _madhhabs) {
        final v = verdictFromString(verdictByProfile[m.key] ?? 'mushbooh');
        if (_severity(v) > _severity(worst)) worst = v;
      }
      return worst;
    }
    return verdictFromString(verdictByProfile[p.key] ?? 'mushbooh');
  }

  static int _severity(Verdict v) => switch (v) {
        Verdict.haram => 3,
        Verdict.mushbooh => 2,
        Verdict.unknown => 1,
        Verdict.halal => 0,
      };
}

/// İçindekiler sözlüğündeki tek kayıt (kelime bazlı eşleşme).
class IngredientEntry {
  final String id;
  final String status;
  final List<String> terms;
  final List<String> exceptions;
  final String reasonTr;
  final String reasonEn;

  const IngredientEntry({
    required this.id,
    required this.status,
    required this.terms,
    required this.exceptions,
    required this.reasonTr,
    required this.reasonEn,
  });

  factory IngredientEntry.fromJson(Map<String, dynamic> j) => IngredientEntry(
        id: j['id'] as String,
        status: j['status'] as String,
        terms: [
          ...List<String>.from(j['terms_tr'] as List? ?? []),
          ...List<String>.from(j['terms_en'] as List? ?? []),
          ...List<String>.from(j['terms_de'] as List? ?? []),
          ...List<String>.from(j['terms_fr'] as List? ?? []),
          ...List<String>.from(j['terms_ar'] as List? ?? []),
          ...List<String>.from(j['terms_id'] as List? ?? []),
        ],
        exceptions: List<String>.from(j['exceptions'] as List? ?? []),
        reasonTr: j['reason_tr'] as String,
        reasonEn: j['reason_en'] as String,
      );
}

/// Tek bir tespit: hangi madde, hangi hüküm, neden (TR + EN; diğer diller EN'e düşer).
class Finding {
  final String label;
  final Verdict verdict;
  final String reasonTr;
  final String reasonEn;
  final bool isNote;

  const Finding({
    required this.label,
    required this.verdict,
    required this.reasonTr,
    required this.reasonEn,
    this.isNote = false,
  });
}

/// Analizin tamamı.
class AnalysisResult {
  final Verdict verdict;
  final List<Finding> findings;

  /// 0..1 — verinin ne kadarına güvenebildiğimiz (içerik listesi var mı,
  /// vegan sinyali var mı). Yeşil kartta bile düşük güven kullanıcıya gösterilir.
  final double confidence;
  final String summaryTr;
  final String summaryEn;

  const AnalysisResult({
    required this.verdict,
    required this.findings,
    required this.confidence,
    required this.summaryTr,
    required this.summaryEn,
  });
}

/// Open Food Facts'ten dönen ürün.
class OffProduct {
  final String barcode;
  final String? name;
  final String? brands;
  final String? ingredientsText;
  final List<String> additiveTags;
  final String? veganStatus; // yes / no / maybe / null
  final String? imageUrl;

  /// OFF kategori etiketleri (ör. "en:chocolate-spreads") — alternatif ürün
  /// önerisi aynı kategoride arama yapar. Liste genelden özele sıralıdır.
  final List<String> categoryTags;

  /// OFF alerjen etiketleri (ör. "en:gluten") — diyet katmanı için.
  final List<String> allergenTags;

  /// OFF vejetaryen analizi (`yes`/`no`/`maybe`/null).
  final String? vegetarianStatus;

  /// OFF "içerebilir" (traces_tags) beyanları — alerjik kullanıcı için
  /// iz miktarda bulaşma uyarısı üretir.
  final List<String> tracesTags;

  /// OFF palm yağı analizi (`yes`/`no`/`maybe`/null).
  final String? palmOilStatus;

  const OffProduct({
    required this.barcode,
    this.name,
    this.brands,
    this.ingredientsText,
    this.additiveTags = const [],
    this.veganStatus,
    this.imageUrl,
    this.categoryTags = const [],
    this.allergenTags = const [],
    this.vegetarianStatus,
    this.tracesTags = const [],
    this.palmOilStatus,
  });
}

/// İsimle arama sonucu satırı (içerik verisi olmadan hafif liste öğesi).
class OffSearchHit {
  final String barcode;
  final String? name;
  final String? brands;
  final String? imageUrl;

  const OffSearchHit({required this.barcode, this.name, this.brands, this.imageUrl});
}
