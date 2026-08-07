import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// E-kod tablosu + içindekiler sözlüğünü yükler ve bellekte tutar.
///
/// Veri uygulamaya gömülüdür (offline çalışır); ileride backend'den
/// imzalı güncelleme alacak şekilde genişletilecek.
class KnowledgeBase {
  final Map<String, EcodeEntry> ecodes;
  final List<IngredientEntry> ingredients;
  final String version;

  const KnowledgeBase({
    required this.ecodes,
    required this.ingredients,
    required this.version,
  });

  static KnowledgeBase fromJsonStrings(String ecodesJson, String ingredientsJson) {
    final e = jsonDecode(ecodesJson) as Map<String, dynamic>;
    final i = jsonDecode(ingredientsJson) as Map<String, dynamic>;
    return KnowledgeBase(
      version: e['version'] as String? ?? '0',
      ecodes: {
        for (final c in (e['codes'] as List))
          (c['code'] as String).toUpperCase(): EcodeEntry.fromJson(c as Map<String, dynamic>),
      },
      ingredients: [
        for (final entry in (i['entries'] as List))
          IngredientEntry.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }

  static Future<KnowledgeBase> loadFromAssets() async {
    final e = await rootBundle.loadString('assets/data/e_codes_v0.json');
    final i = await rootBundle.loadString('assets/data/ingredients_v0.json');
    return fromJsonStrings(e, i);
  }
}
