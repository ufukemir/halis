import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';
import 'result_screen.dart';

/// Süpermarket modu: kamera açık kalır, art arda tarama; her sonuç oturum
/// sepetine eklenir, altta özet çubuğu ve liste. Satıra dokununca tam kart.
class MarketModeScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const MarketModeScreen({super.key, required this.profile, required this.kb});

  @override
  State<MarketModeScreen> createState() => _MarketModeScreenState();
}

class _MarketItem {
  final String barcode;
  final String title;
  final Verdict verdict;
  const _MarketItem({required this.barcode, required this.title, required this.verdict});
}

class _MarketModeScreenState extends State<MarketModeScreen> {
  final _controller = MobileScannerController(
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
  );
  final _items = <_MarketItem>[];
  final _seen = <String>{};
  bool _lookupBusy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_lookupBusy) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .firstOrNull;
    if (value == null || _seen.contains(value)) return;
    _seen.add(value);
    setState(() => _lookupBusy = true);
    try {
      final s = S.of(context);
      final product = await OffApi().fetchProduct(value);
      final Verdict verdict;
      final String title;
      if (product == null) {
        verdict = Verdict.unknown;
        title = value;
      } else {
        final r = RuleEngine(widget.kb).analyze(
          profile: widget.profile,
          ingredientsText: product.ingredientsText,
          additiveTags: product.additiveTags,
          veganStatus: product.veganStatus,
        );
        verdict = r.verdict;
        title = [if (product.brands != null) product.brands!, product.name ?? value].join(' ');
        await HistoryService().add(HistoryEntry(
            title: title,
            verdict: verdict,
            date: DateTime.now(),
            ingredientsText: product.ingredientsText,
            additiveTags: product.additiveTags));
      }
      if (!mounted) return;
      _hapticFor(verdict); // telefona bakmadan raf arası kullanım
      setState(() => _items.insert(0, _MarketItem(barcode: value, title: title, verdict: verdict)));
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: verdictStyle(verdict).$1,
          content: Row(
            children: [
              Icon(verdictStyle(verdict).$2, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${s.verdictTitle(verdict)} · $title',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ));
    } catch (_) {
      _seen.remove(value); // ağ hatası: aynı barkod tekrar denenebilsin
    } finally {
      if (mounted) setState(() => _lookupBusy = false);
    }
  }

  /// Hüküm başına ayrık titreşim deseni: yeşil tek hafif, turuncu çift orta,
  /// kırmızı uzun — ekrana bakmadan ayırt edilir.
  Future<void> _hapticFor(Verdict v) async {
    switch (v) {
      case Verdict.halal:
        await HapticFeedback.lightImpact();
      case Verdict.mushbooh:
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.mediumImpact();
      case Verdict.haram:
        await HapticFeedback.vibrate();
      case Verdict.unknown:
        await HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final clean = _items.where((i) => i.verdict == Verdict.halal).length;
    final flagged =
        _items.where((i) => i.verdict == Verdict.haram || i.verdict == Verdict.mushbooh).length;
    return Scaffold(
      appBar: AppBar(title: Text(s.marketMode)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                if (_lookupBusy) const Center(child: CircularProgressIndicator()),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    s.marketHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.marketSummary(_items.length, clean, flagged))),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                for (final item in _items)
                  ListTile(
                    dense: true,
                    leading: Icon(verdictStyle(item.verdict).$2,
                        color: verdictStyle(item.verdict).$1,
                        semanticLabel: s.verdictTitle(item.verdict)),
                    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ResultScreen(
                          barcode: item.barcode, profile: widget.profile, kb: widget.kb),
                    )),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
