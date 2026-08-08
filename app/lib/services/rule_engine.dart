import '../models/models.dart';
import 'knowledge_base.dart';

/// Halis hüküm motoru — tamamen yerel, deterministik, muhafazakâr.
///
/// Temel politika:
///  * Herhangi bir haram tespit → sonuç HARAM.
///  * Haram yoksa herhangi bir şüpheli tespit → sonuç ŞÜPHELİ.
///  * İçerik verisi yoksa asla yeşil yakmayız → UNKNOWN (fotoğraf iste).
///  * LLM çıktısı bu motoru asla geçersiz kılamaz; yeşil yalnız buradan çıkar.
class RuleEngine {
  final KnowledgeBase kb;

  RuleEngine(this.kb);

  static final _ecodePattern = RegExp(r'\bE[ -]?(\d{3,4})([a-f])?\b', caseSensitive: false);

  // TR/DE/FR/Arapça karakterleri de kelime içi sayan sınır tanımı.
  // Arapça'da yalnız HARF aralıkları alınır (noktalama ؍،؟ sınır sayılmalı).
  static const _letters =
      'a-zA-ZçğıöşüÇĞİÖŞÜäöüÄÖÜßàâéèêëîïôûùœÀÂÉÈÊËÎÏÔÛÙŒء-يٮ-ۓە';

  /// [ingredientsText] etiketteki içerik listesi (herhangi bir dil),
  /// [additiveTags] OFF `additives_tags` (ör. `en:e471`),
  /// [veganStatus] OFF vegan analizi (`yes`/`no`/`maybe`/null).
  AnalysisResult analyze({
    required Profile profile,
    String? ingredientsText,
    List<String> additiveTags = const [],
    String? veganStatus,
  }) {
    final text = (ingredientsText ?? '').toLowerCase();
    final hasText = text.trim().isNotEmpty;
    final findings = <Finding>[];

    if (!hasText && additiveTags.isEmpty) {
      return const AnalysisResult(
        verdict: Verdict.unknown,
        findings: [],
        confidence: 0,
        summaryTr:
            'Bu ürün için içerik verisi yok. Etiketin fotoğrafını çekerek analiz edebilir ve veritabanına katkıda bulunabilirsiniz.',
        summaryEn:
            'No ingredient data for this product. You can analyze it by taking a photo of the label.',
      );
    }

    // 1) Kelime bazlı içerik taraması.
    for (final entry in kb.ingredients) {
      final match = _firstTermMatch(text, entry);
      if (match == null) continue;
      switch (entry.status) {
        case 'haram':
        case 'haram_unless_certified':
          findings.add(Finding(
              label: match, verdict: Verdict.haram, reasonTr: entry.reasonTr, reasonEn: entry.reasonEn));
        case 'mushbooh':
          findings.add(Finding(
              label: match, verdict: Verdict.mushbooh, reasonTr: entry.reasonTr, reasonEn: entry.reasonEn));
        case 'mushbooh_mild':
          // Hafif şüpheliler (peynir altı suyu, laktoz vb.) yalnız temkinli
          // profilde hükmü etkiler; diğer profillerde bilgi notu olarak kalır.
          findings.add(Finding(
            label: match,
            verdict: profile == Profile.temkinli ? Verdict.mushbooh : Verdict.halal,
            reasonTr: entry.reasonTr,
            reasonEn: entry.reasonEn,
            isNote: profile != Profile.temkinli,
          ));
        case 'halal_note':
          findings.add(Finding(
              label: match,
              verdict: Verdict.halal,
              reasonTr: entry.reasonTr,
              reasonEn: entry.reasonEn,
              isNote: true));
      }
    }

    // 2) E-kodları: metinden + OFF etiketlerinden + isim (alias) eşleşmelerinden
    //    birleşik küme. Etiketler katkıyı her zaman koduyla yazmaz
    //    ("polysorbate 80", "stéarate de magnésium"...).
    final codes = <String>{
      for (final m in _ecodePattern.allMatches(text))
        'E${m.group(1)}${m.group(2) ?? ''}'.toUpperCase(),
      for (final tag in additiveTags) _codeFromTag(tag),
      if (hasText)
        for (final entry in kb.ecodes.values)
          if (_matchesAlias(text, entry)) entry.code,
    }..removeWhere((c) => c.isEmpty);

    for (final code in codes) {
      final entry = kb.ecodes[code] ?? _baseCodeFallback(code);
      if (entry == null) {
        findings.add(Finding(
          label: code,
          verdict: Verdict.mushbooh,
          reasonTr: 'Bu katkı maddesi henüz veritabanımızda değil; temkinli davranıyoruz.',
          reasonEn: 'This additive is not yet in our database; we err on the side of caution.',
        ));
        continue;
      }
      final v = entry.verdictFor(profile);
      if (v != Verdict.halal) {
        findings.add(Finding(
          label: '${entry.code} — ${entry.nameTr}',
          verdict: v,
          reasonTr: entry.reasonTr,
          reasonEn: entry.reasonEn,
        ));
      }
    }

    // 3) Nihai hüküm.
    final hasHaram = findings.any((f) => f.verdict == Verdict.haram);
    final hasMushbooh = findings.any((f) => f.verdict == Verdict.mushbooh);

    if (hasHaram) {
      return AnalysisResult(
        verdict: Verdict.haram,
        findings: _sorted(findings),
        confidence: 0.9,
        summaryTr: 'Haram veya haram kaynaklı olma ihtimali yüksek bileşen tespit edildi.',
        summaryEn: 'An ingredient that is haram or very likely haram-derived was detected.',
      );
    }
    if (hasMushbooh) {
      return AnalysisResult(
        verdict: Verdict.mushbooh,
        findings: _sorted(findings),
        confidence: 0.75,
        summaryTr:
            'Kaynağı doğrulanamayan bileşen(ler) var. Üretici beyanı veya helal sertifika olmadan kesin hüküm verilemez.',
        summaryEn:
            'Some ingredients have unverifiable sources. No definite assessment without producer declaration or halal certification.',
      );
    }

    // Temiz görünüyor — güven, veri kalitesine göre ayarlanır.
    final vegan = veganStatus == 'yes';
    return AnalysisResult(
      verdict: Verdict.halal,
      findings: _sorted(findings),
      confidence: vegan ? 0.95 : (hasText ? 0.8 : 0.6),
      summaryTr: vegan
          ? 'İçerikte hayvansal bileşen görünmüyor (vegan işaretli ürün).'
          : 'İçerik listesinde bilinen haram/şüpheli bileşen bulunamadı. Etiketteki "helal" logosunu da kontrol etmenizi öneririz.',
      summaryEn: vegan
          ? 'No animal-derived ingredients found (product marked vegan).'
          : 'No known haram/doubtful ingredients found in the list. We still recommend checking for a "halal" logo on the label.',
    );
  }

  /// Eşleşen ilk terimi döndürür; istisna kalıbı metinde geçiyorsa eşleşme iptal.
  String? _firstTermMatch(String text, IngredientEntry entry) {
    for (final exception in entry.exceptions) {
      if (text.contains(exception.toLowerCase())) return null;
    }
    for (final term in entry.terms) {
      final t = RegExp.escape(term.toLowerCase());
      final re = RegExp('(?<![$_letters])$t(?![$_letters])');
      if (re.hasMatch(text)) return term;
    }
    return null;
  }

  /// E-kod isim eşleşmesi: aliases metinde kelime sınırında geçiyor mu?
  /// İstisna kalıbı (ör. "bitkisel gliserin") geçiyorsa eşleşme iptal.
  bool _matchesAlias(String text, EcodeEntry entry) {
    if (entry.aliases.isEmpty) return false;
    for (final exception in entry.aliasExceptions) {
      if (text.contains(exception)) return false;
    }
    for (final alias in entry.aliases) {
      final a = RegExp.escape(alias);
      final re = RegExp('(?<![$_letters])$a(?![$_letters])');
      if (re.hasMatch(text)) return true;
    }
    return false;
  }

  String _codeFromTag(String tag) {
    // "en:e471" -> "E471"
    final m = RegExp(r'e(\d{3,4}[a-f]?)$', caseSensitive: false).firstMatch(tag);
    return m == null ? '' : 'E${m.group(1)}'.toUpperCase();
  }

  /// "E150a" tabloda yoksa "E150" gibi ana koda düşmeyi dener (tersi değil:
  /// alt varyant tabloda ayrıca tanımlıysa o kazanır).
  EcodeEntry? _baseCodeFallback(String code) {
    final m = RegExp(r'^(E\d{3,4})[a-f]$').firstMatch(code);
    if (m == null) return null;
    return kb.ecodes[m.group(1)];
  }

  List<Finding> _sorted(List<Finding> f) {
    const order = {Verdict.haram: 0, Verdict.mushbooh: 1, Verdict.halal: 2, Verdict.unknown: 3};
    return [...f]..sort((a, b) => order[a.verdict]!.compareTo(order[b.verdict]!));
  }
}
