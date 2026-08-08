import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/knowledge_base.dart';
import '../widgets/verdict_view.dart';

/// E-kod ansiklopedisi: gömülü tablonun aranabilir başvuru ekranı.
/// "E471 helal mi?" sorusunun taramasız cevabı — ASO uzun kuyruğunun
/// uygulama içi karşılığı.
class EncyclopediaScreen extends StatefulWidget {
  final Profile profile;
  final KnowledgeBase kb;

  const EncyclopediaScreen({super.key, required this.profile, required this.kb});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  String _query = '';
  late final List<EcodeEntry> _all = widget.kb.ecodes.values.toList()
    ..sort((a, b) => _codeNum(a.code).compareTo(_codeNum(b.code)));

  static int _codeNum(String code) =>
      int.tryParse(code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  List<EcodeEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return [
      for (final e in _all)
        if (e.code.toLowerCase().contains(q) ||
            e.nameTr.toLowerCase().contains(q) ||
            e.nameEn.toLowerCase().contains(q) ||
            e.aliases.any((a) => a.contains(q)))
          e,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final entries = _filtered;
    return Scaffold(
      appBar: AppBar(title: Text(s.encyclopediaTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.encyclopediaSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final v = e.verdictFor(widget.profile);
                final (color, icon) = verdictStyle(v);
                return ExpansionTile(
                  leading: Icon(icon, color: color),
                  title: Text('${e.code} — ${s.useTurkishReasons ? e.nameTr : e.nameEn}'),
                  subtitle: Text(s.verdictTitle(v), style: TextStyle(color: color)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.useTurkishReasons ? e.reasonTr : e.reasonEn),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final p in Profile.values)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(verdictStyle(e.verdictFor(p)).$2,
                                size: 16, color: verdictStyle(e.verdictFor(p)).$1),
                            label: Text('${s.profileName(p)}: ${s.verdictTitle(e.verdictFor(p))}',
                                style: const TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
