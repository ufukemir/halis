import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'knowledge_base.dart';
import 'rule_engine.dart';

class HistoryEntry {
  final String title;
  final Verdict verdict;
  final DateTime date;

  /// Yeniden analiz için saklanan girdiler (profil değişince hüküm tazelenir).
  /// Eski kayıtlarda boş olabilir — o kayıtların hükmü olduğu gibi kalır.
  final String? ingredientsText;
  final List<String> additiveTags;

  const HistoryEntry({
    required this.title,
    required this.verdict,
    required this.date,
    this.ingredientsText,
    this.additiveTags = const [],
  });

  bool get canReanalyze =>
      (ingredientsText?.trim().isNotEmpty ?? false) || additiveTags.isNotEmpty;

  HistoryEntry withVerdict(Verdict v) => HistoryEntry(
      title: title, verdict: v, date: date,
      ingredientsText: ingredientsText, additiveTags: additiveTags);

  Map<String, dynamic> toJson() => {
        't': title,
        'v': verdict.name,
        'd': date.toIso8601String(),
        if (ingredientsText != null) 'i': ingredientsText,
        if (additiveTags.isNotEmpty) 'a': additiveTags,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        title: j['t'] as String,
        verdict: verdictFromString(j['v'] as String),
        date: DateTime.tryParse(j['d'] as String? ?? '') ?? DateTime.now(),
        ingredientsText: j['i'] as String?,
        additiveTags: List<String>.from(j['a'] as List? ?? []),
      );
}

/// Aylık tarama istatistikleri ("bu ay 47 ürün taradın, 12 şüpheli yakaladın").
class HistoryStats {
  final int total;
  final int flagged; // haram + mushbooh

  const HistoryStats({required this.total, required this.flagged});
}

/// Yerel tarama geçmişi (cihazda kalır; senkron yok — mahremiyet ilkesi).
class HistoryService {
  static const _key = 'scan_history_v1';
  static const _max = 50;

  Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List) HistoryEntry.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> add(HistoryEntry entry) async {
    final entries = await load();
    entries.insert(0, entry);
    if (entries.length > _max) entries.removeRange(_max, entries.length);
    await _save(entries);
  }

  /// Profil değişince: girdisi saklanan kayıtların hükmü yeni profille
  /// yeniden hesaplanır (tutarlılık — liste, seçili profilin gözünden görünür).
  Future<List<HistoryEntry>> reanalyze(KnowledgeBase kb, Profile profile) async {
    final engine = RuleEngine(kb);
    final entries = await load();
    final updated = [
      for (final e in entries)
        e.canReanalyze
            ? e.withVerdict(engine
                .analyze(
                  profile: profile,
                  ingredientsText: e.ingredientsText,
                  additiveTags: e.additiveTags,
                )
                .verdict)
            : e,
    ];
    await _save(updated);
    return updated;
  }

  /// İçinde bulunulan ayın istatistikleri.
  Future<HistoryStats> statsThisMonth() async {
    final now = DateTime.now();
    final entries = (await load())
        .where((e) => e.date.year == now.year && e.date.month == now.month);
    return HistoryStats(
      total: entries.length,
      flagged: entries
          .where((e) => e.verdict == Verdict.haram || e.verdict == Verdict.mushbooh)
          .length,
    );
  }

  Future<void> _save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final e in entries) e.toJson()]));
  }
}
