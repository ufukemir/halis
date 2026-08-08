import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

/// İki ürünü yan yana karşılaştırma: hangisi daha temiz?
class CompareScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const CompareScreen({super.key, required this.profile, required this.kb});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _Slot {
  final controller = TextEditingController();
  OffProduct? product;
  AnalysisResult? result;
  bool busy = false;
  bool notFound = false;

  void dispose() => controller.dispose();
}

class _CompareScreenState extends State<CompareScreen> {
  final _slots = [_Slot(), _Slot()];

  @override
  void dispose() {
    for (final s in _slots) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _lookup(_Slot slot) async {
    final code = slot.controller.text.trim();
    if (code.isEmpty) return;
    setState(() {
      slot.busy = true;
      slot.notFound = false;
      slot.product = null;
      slot.result = null;
    });
    try {
      final product = await OffApi().fetchProduct(code);
      if (product == null) {
        setState(() => slot.notFound = true);
      } else {
        final result = RuleEngine(widget.kb).analyze(
          profile: widget.profile,
          ingredientsText: product.ingredientsText,
          additiveTags: product.additiveTags,
          veganStatus: product.veganStatus,
        );
        setState(() {
          slot.product = product;
          slot.result = result;
        });
      }
    } catch (_) {
      if (mounted) setState(() => slot.notFound = true);
    } finally {
      if (mounted) setState(() => slot.busy = false);
    }
  }

  Future<void> _scanInto(_Slot slot) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (code == null || code.isEmpty) return;
    slot.controller.text = code;
    await _lookup(slot);
  }

  Widget _slotCard(_Slot slot) {
    final s = S.of(context);
    final product = slot.product;
    final result = slot.result;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: slot.controller,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _lookup(slot),
                decoration: InputDecoration(
                  labelText: s.manualBarcode,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => _scanInto(slot),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (slot.busy) const CircularProgressIndicator(),
              if (slot.notFound) Text(s.notFound, textAlign: TextAlign.center),
              if (product != null && result != null) ...[
                if (product.imageUrl != null)
                  Image.network(product.imageUrl!, height: 64,
                      errorBuilder: (_, _, _) => const Icon(Icons.fastfood, size: 48))
                else
                  const Icon(Icons.fastfood, size: 48),
                const SizedBox(height: 8),
                Text(
                  product.name ?? product.barcode,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: verdictStyle(result.verdict).$1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(verdictStyle(result.verdict).$2, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(s.verdictTitle(result.verdict),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.findings.where((f) => !f.isNote).length} ${s.findings.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ResultScreen(
                        barcode: product.barcode, profile: widget.profile, kb: widget.kb),
                  )),
                  child: Text(s.result),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.compareTitle)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slotCard(_slots[0]),
            const SizedBox(width: 8),
            _slotCard(_slots[1]),
          ],
        ),
      ),
    );
  }
}
