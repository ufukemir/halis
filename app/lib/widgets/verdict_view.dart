import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/share_service.dart';

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

  /// Paylaşım/bildirim bağlamı: ürün adı ya da etiket metni özeti.
  /// null → düğme satırı gizlenir (ör. bağlamsız önizlemeler).
  final String? contextTitle;

  /// Bildirim e-postasına giden veri sürümü (E-kod tablosu).
  final String dataVersion;

  const VerdictView({
    super.key,
    required this.result,
    required this.profile,
    this.contextTitle,
    this.dataVersion = '?',
  });

  String _verdictLine(S s) =>
      '${s.verdictTitle(result.verdict)} · ${s.profileLabel}: ${s.profileName(profile)}';

  void _share(S s) {
    final text = ShareService.buildShareText(
      title: contextTitle!,
      verdictLine: _verdictLine(s),
      findingLines: [
        for (final f in result.findings.where((f) => !f.isNote))
          '${f.label}: ${s.useTurkishReasons ? f.reasonTr : f.reasonEn}',
      ],
      footer: s.sharedWith,
    );
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _report(S s) {
    launchUrl(ShareService.feedbackMailUri(
      subject: s.reportSubject,
      title: contextTitle!,
      verdictLine: _verdictLine(s),
      dataVersion: dataVersion,
      lang: s.lang,
    ));
  }

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
        if (contextTitle != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _report(s),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(s.reportWrong),
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                onPressed: () => _share(s),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(s.share),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(s.disclaimer, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
