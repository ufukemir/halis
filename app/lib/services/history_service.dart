import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class HistoryEntry {
  final String title;
  final Verdict verdict;
  final DateTime date;

  const HistoryEntry({required this.title, required this.verdict, required this.date});

  Map<String, dynamic> toJson() => {'t': title, 'v': verdict.name, 'd': date.toIso8601String()};

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        title: j['t'] as String,
        verdict: verdictFromString(j['v'] as String),
        date: DateTime.tryParse(j['d'] as String? ?? '') ?? DateTime.now(),
      );
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
    final prefs = await SharedPreferences.getInstance();
    final entries = await load();
    entries.insert(0, entry);
    if (entries.length > _max) entries.removeRange(_max, entries.length);
    await prefs.setString(_key, jsonEncode([for (final e in entries) e.toJson()]));
  }
}
