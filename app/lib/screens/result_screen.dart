import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/alternatives_service.dart';
import '../services/diet_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import '../services/premium_service.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';
import 'label_screen.dart';
import 'paywall_screen.dart';

/// Barkod → OFF sorgusu → kural motoru → renkli sonuç kartı.
class ResultScreen extends StatefulWidget {
  final String barcode;
  final Profile profile;
  final KnowledgeBase kb;

  const ResultScreen({
    super.key,
    required this.barcode,
    required this.profile,
    required this.kb,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final Future<(OffProduct?, AnalysisResult?)> _future = _load();
  ProductFlag? _flag;

  @override
  void initState() {
    super.initState();
    FavoritesService().flagOf(widget.barcode).then((f) {
      if (mounted) setState(() => _flag = f);
    });
  }

  Future<void> _toggleFlag(OffProduct product, AnalysisResult result, ProductFlag flag) async {
    final next = await FavoritesService().toggle(FlaggedProduct(
      barcode: product.barcode,
      title: [if (product.brands != null) product.brands!, product.name ?? product.barcode].join(' '),
      verdict: result.verdict,
      flag: flag,
      date: DateTime.now(),
    ));
    if (mounted) setState(() => _flag = next);
  }

  Future<(OffProduct?, AnalysisResult?)> _load() async {
    final product = await OffApi().fetchProduct(widget.barcode);
    if (product == null) return (null, null);
    final result = RuleEngine(widget.kb).analyze(
      profile: widget.profile,
      ingredientsText: product.ingredientsText,
      additiveTags: product.additiveTags,
      veganStatus: product.veganStatus,
    );
    await HistoryService().add(HistoryEntry(
      title: product.name ?? widget.barcode,
      verdict: result.verdict,
      date: DateTime.now(),
      ingredientsText: product.ingredientsText,
      additiveTags: product.additiveTags,
    ));
    return (product, result);
  }

  void _openLabelFlow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LabelScreen(
          profile: widget.profile,
          kb: widget.kb,
          // Barkod bilinerek gelindi → katkı akışı (fotoğrafı OFF'a yükleme)
          // önerilebilir; OFF Türkiye kapsam açığını kullanıcı katkısı kapatır.
          barcode: widget.barcode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.result)),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Message(icon: Icons.wifi_off, text: s.networkError);
          }
          final (product, result) = snapshot.data!;
          if (product == null) {
            return _Message(
              icon: Icons.search_off,
              text: s.notFound,
              action: FilledButton.icon(
                onPressed: _openLabelFlow,
                icon: const Icon(Icons.photo_camera),
                label: Text(s.analyzeLabel),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: product.imageUrl != null
                    ? Image.network(product.imageUrl!, width: 48,
                        errorBuilder: (_, _, _) => const Icon(Icons.fastfood))
                    : const Icon(Icons.fastfood),
                title: Text(product.name ?? s.unnamedProduct),
                subtitle: Text([
                  if (product.brands != null) product.brands!,
                  product.barcode,
                ].join(' · ')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _flag == ProductFlag.fav ? Icons.bookmark : Icons.bookmark_outline,
                        color: _flag == ProductFlag.fav
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: s.favorites,
                      onPressed: () => _toggleFlag(product, result!, ProductFlag.fav),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.block,
                        color: _flag == ProductFlag.avoid ? const Color(0xFFB3261E) : null,
                      ),
                      tooltip: s.avoided,
                      onPressed: () => _toggleFlag(product, result!, ProductFlag.avoid),
                    ),
                  ],
                ),
              ),
              VerdictView(
                result: result!,
                profile: widget.profile,
                contextTitle: [
                  if (product.brands != null) product.brands!,
                  product.name ?? product.barcode,
                ].join(' '),
                dataVersion: widget.kb.version,
              ),
              // Diyet/alerjen uyarıları — helal hükmünden ayrı, bilgilendirme.
              _DietWarnings(product: product),
              // Temiz alternatif önerisi: yalnız sorunlu üründe ve kategori
              // verisi varsa gösterilir (premium'un ana kozu).
              if (result.verdict != Verdict.halal &&
                  result.verdict != Verdict.unknown &&
                  product.categoryTags.isNotEmpty)
                _AlternativesSection(product: product, profile: widget.profile, kb: widget.kb),
              if (product.ingredientsText != null)
                ExpansionTile(
                  title: Text(s.ingredientsLabel),
                  children: [
                    Padding(padding: const EdgeInsets.all(16), child: Text(product.ingredientsText!)),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Kullanıcının seçtiği hassasiyetlere göre alerjen/diyet uyarı çipleri.
/// Hüküm kartından ayrı durur; helal rengini asla etkilemez.
class _DietWarnings extends StatelessWidget {
  final OffProduct product;

  const _DietWarnings({required this.product});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder(
      future: DietService().warningsForProduct(product),
      builder: (context, snapshot) {
        final warnings = snapshot.data ?? const <String>[];
        if (warnings.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final w in warnings)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.warning_amber, size: 16, color: Color(0xFFB86E00)),
                  label: Text(s.allergenName(w), style: const TextStyle(fontSize: 12)),
                  side: const BorderSide(color: Color(0xFFB86E00)),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Temiz alternatifler bölümü: premium'da kural motorundan yeşil çıkan
/// aynı-kategori ürünleri listeler; ücretsizde paywall'a götüren tanıtım kartı.
class _AlternativesSection extends StatefulWidget {
  final OffProduct product;
  final Profile profile;
  final KnowledgeBase kb;

  const _AlternativesSection({required this.product, required this.profile, required this.kb});

  @override
  State<_AlternativesSection> createState() => _AlternativesSectionState();
}

class _AlternativesSectionState extends State<_AlternativesSection> {
  late final Future<List<OffProduct>?> _future = _load();

  /// null → premium değil (tanıtım göster); liste → premium sonuçları.
  Future<List<OffProduct>?> _load() async {
    if (!await PremiumService.isPremium()) return null;
    return AlternativesService(api: OffApi(), kb: widget.kb)
        .findClean(widget.product, widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final alts = snapshot.data;
        if (alts == null) {
          // Ücretsiz katman: tanıtım kartı → paywall.
          return Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: Text(s.alternativesTitle),
              subtitle: Text(s.alternativesTeaser),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(s.alternativesTitle, style: Theme.of(context).textTheme.titleMedium),
            ),
            if (alts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(s.alternativesEmpty, style: Theme.of(context).textTheme.bodySmall),
              ),
            for (final alt in alts)
              Card(
                child: ListTile(
                  leading: alt.imageUrl != null
                      ? Image.network(alt.imageUrl!, width: 40,
                          errorBuilder: (_, _, _) => const Icon(Icons.fastfood))
                      : const Icon(Icons.fastfood),
                  title: Text(alt.name ?? alt.barcode, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: alt.brands != null ? Text(alt.brands!, maxLines: 1) : null,
                  trailing: Icon(Icons.check_circle, color: verdictStyle(Verdict.halal).$1),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ResultScreen(
                        barcode: alt.barcode, profile: widget.profile, kb: widget.kb),
                  )),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
