import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/history_service.dart';
import '../services/knowledge_base.dart';
import '../services/off_api.dart';
import '../services/rule_engine.dart';
import '../widgets/verdict_view.dart';
import 'label_screen.dart';

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
    ));
    return (product, result);
  }

  void _openLabelFlow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LabelScreen(profile: widget.profile, kb: widget.kb)),
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
              ),
              VerdictView(result: result!, profile: widget.profile),
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
