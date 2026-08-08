/// Halis — temel modeller.
///
/// Hüküm sıralaması önem sırasına göredir: haram > mushbooh > halal.
/// `unknown` yalnız veri yetersizliğinde döner ve asla yeşil gösterilmez.
enum Verdict { halal, mushbooh, haram, unknown }

/// Kullanıcının seçtiği hassasiyet profili.
enum Profile { temkinli, genislik, diyanet }

extension ProfileKey on Profile {
  String get key => switch (this) {
        Profile.temkinli => 'temkinli',
        Profile.genislik => 'genislik',
        Profile.diyanet => 'diyanet',
      };

  String get labelTr => switch (this) {
        Profile.temkinli => 'Temkinli',
        Profile.genislik => 'Genişlik',
        Profile.diyanet => 'Diyanet',
      };
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

  Verdict verdictFor(Profile p) =>
      verdictFromString(verdictByProfile[p.key] ?? 'mushbooh');
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

  const OffProduct({
    required this.barcode,
    this.name,
    this.brands,
    this.ingredientsText,
    this.additiveTags = const [],
    this.veganStatus,
    this.imageUrl,
  });
}
