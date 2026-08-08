import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Kullanıcının işaretlediği ürünler: onayladıkların (favori) ve
/// kaçındıkların (kara liste). Cihazda kalır — mahremiyet ilkesi.
enum ProductFlag { fav, avoid }

class FlaggedProduct {
  final String barcode;
  final String title;
  final Verdict verdict;
  final ProductFlag flag;
  final DateTime date;

  const FlaggedProduct({
    required this.barcode,
    required this.title,
    required this.verdict,
    required this.flag,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'b': barcode,
        't': title,
        'v': verdict.name,
        'f': flag.name,
        'd': date.toIso8601String(),
      };

  factory FlaggedProduct.fromJson(Map<String, dynamic> j) => FlaggedProduct(
        barcode: j['b'] as String,
        title: j['t'] as String,
        verdict: verdictFromString(j['v'] as String),
        flag: j['f'] == 'avoid' ? ProductFlag.avoid : ProductFlag.fav,
        date: DateTime.tryParse(j['d'] as String? ?? '') ?? DateTime.now(),
      );
}

class FavoritesService {
  static const _key = 'flagged_products_v1';

  Future<List<FlaggedProduct>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          FlaggedProduct.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<ProductFlag?> flagOf(String barcode) async {
    for (final p in await load()) {
      if (p.barcode == barcode) return p.flag;
    }
    return null;
  }

  /// Aynı bayrağa ikinci dokunuş işareti kaldırır; farklı bayrak üzerine yazar.
  /// Dönüş: yeni durum (null → işaret kaldırıldı).
  Future<ProductFlag?> toggle(FlaggedProduct product) async {
    final entries = await load();
    final existing = entries.indexWhere((p) => p.barcode == product.barcode);
    ProductFlag? result;
    if (existing >= 0 && entries[existing].flag == product.flag) {
      entries.removeAt(existing);
      result = null;
    } else {
      if (existing >= 0) entries.removeAt(existing);
      entries.insert(0, product);
      result = product.flag;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final e in entries) e.toJson()]));
    return result;
  }
}
