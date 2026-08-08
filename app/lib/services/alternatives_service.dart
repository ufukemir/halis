import '../models/models.dart';
import 'knowledge_base.dart';
import 'off_api.dart';
import 'rule_engine.dart';

/// Temiz alternatif önerisi (premium'un ana kozu — docs/03 v1.5).
///
/// Şüpheli/haram çıkan ürünün EN ÖZEL kategorisinden adaylar çekilir ve her
/// aday YEREL kural motorundan geçirilir: yalnız içerik verisi olan ve seçili
/// profilde YEŞİL çıkan ürünler önerilir. LLM yok, OFF'un kendi skoru yok —
/// öneri de aynı güven zincirinden geçer (yanlış yeşil koruması burada da).
class AlternativesService {
  final OffApi api;
  final KnowledgeBase kb;

  AlternativesService({required this.api, required this.kb});

  /// En fazla [limit] temiz alternatif. Kategori yoksa/aday çıkmazsa boş liste;
  /// ağ hatasında da boş liste — öneri akışı sonuç kartını asla bloke etmez.
  Future<List<OffProduct>> findClean(
    OffProduct product,
    Profile profile, {
    int limit = 3,
  }) async {
    // OFF kategori listesi genelden özele gider; en özel (son) etiket en
    // isabetli aday havuzunu verir.
    if (product.categoryTags.isEmpty) return const [];
    final category = product.categoryTags.last;
    final List<OffProduct> candidates;
    try {
      candidates = await api.fetchCategoryProducts(category);
    } catch (_) {
      return const [];
    }
    final engine = RuleEngine(kb);
    final clean = <OffProduct>[];
    for (final c in candidates) {
      if (c.barcode == product.barcode) continue;
      final hasData = (c.ingredientsText?.trim().isNotEmpty ?? false) || c.additiveTags.isNotEmpty;
      if (!hasData) continue; // verisiz ürün önerilmez (asla körlemesine yeşil)
      final r = engine.analyze(
        profile: profile,
        ingredientsText: c.ingredientsText,
        additiveTags: c.additiveTags,
        veganStatus: c.veganStatus,
      );
      if (r.verdict == Verdict.halal) {
        clean.add(c);
        if (clean.length >= limit) break;
      }
    }
    return clean;
  }
}
