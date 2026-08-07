import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';

(Color, IconData) verdictStyle(Verdict v) => switch (v) {
      Verdict.halal => (const Color(0xFF1B7A43), Icons.check_circle),
      Verdict.mushbooh => (const Color(0xFFB86E00), Icons.help),
      Verdict.haram => (const Color(0xFFB3261E), Icons.cancel),
      Verdict.unknown => (const Color(0xFF5F6368), Icons.camera_alt),
    };

/// Renkli hüküm kartı + tespit listesi + disclaimer. Barkod ve etiket
/// akışlarının ortak sonuç görünümü.
class VerdictView extends StatelessWidget {
  final AnalysisResult result;
  final Profile profile;

  const VerdictView({super.key, required this.result, required this.profile});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (color, icon) = verdictStyle(result.verdict);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 56),
                const SizedBox(height: 8),
                Text(
                  s.verdictTitle(result.verdict),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  s.useTurkishReasons ? result.summaryTr : result.summaryEn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.profileLabel}: ${s.profileName(profile)} · ${s.confidence}: %${(result.confidence * 100).round()}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (result.findings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(s.findings, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final f in result.findings)
            Card(
              child: ListTile(
                leading: Icon(
                  f.isNote ? Icons.info_outline : verdictStyle(f.verdict).$2,
                  color: f.isNote ? const Color(0xFF5F6368) : verdictStyle(f.verdict).$1,
                ),
                title: Text(f.label),
                subtitle: Text(s.useTurkishReasons ? f.reasonTr : f.reasonEn),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Text(s.disclaimer, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
