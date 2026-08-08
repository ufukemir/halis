import 'dart:convert';

import 'package:http/http.dart' as http;

/// Backend'in /v1/normalize-label yanıtı — hüküm İÇERMEZ.
/// LLM yalnız OCR metnini ayıklar; helal/haram kararı daima yerel kural motorundadır.
class NormalizedLabel {
  final List<String> ingredients;
  final List<String> eCodes;
  final List<String> animalDerivedTerms;
  final List<String> alcoholTerms;
  final String ocrQuality; // good | partial | poor

  const NormalizedLabel({
    required this.ingredients,
    required this.eCodes,
    required this.animalDerivedTerms,
    required this.alcoholTerms,
    required this.ocrQuality,
  });

  factory NormalizedLabel.fromJson(Map<String, dynamic> j) => NormalizedLabel(
        ingredients: List<String>.from(j['ingredients'] as List? ?? []),
        eCodes: List<String>.from(j['e_codes'] as List? ?? []),
        animalDerivedTerms: List<String>.from(j['animal_derived_terms'] as List? ?? []),
        alcoholTerms: List<String>.from(j['alcohol_terms'] as List? ?? []),
        ocrQuality: j['ocr_quality'] as String? ?? 'partial',
      );

  /// Kural motoruna verilecek birleşik metin: normalize içerik listesi +
  /// LLM'in işaretlediği terimler (motor kendi sözlüğüyle yeniden tarar).
  String get combinedText => [
        ingredients.join(', '),
        eCodes.join(', '),
        animalDerivedTerms.join(', '),
        alcoholTerms.join(', '),
      ].where((s) => s.isNotEmpty).join(', ');
}

/// Halis backend istemcisi. Taban adres derleme zamanında verilir:
///   flutter run --dart-define=HALIS_API_URL=https://api.halis.app
/// Tanımsızsa servis kapalıdır ve akış tamamen yerel çalışır.
class NormalizeApi {
  static const baseUrl = String.fromEnvironment('HALIS_API_URL');

  static bool get isConfigured => baseUrl.isNotEmpty;

  final http.Client _client;

  NormalizeApi({http.Client? client}) : _client = client ?? http.Client();

  /// Ham OCR metnini normalize eder. Hata/zaman aşımı durumunda null döner —
  /// çağıran taraf ham metinle yerel analize düşer (backend hiçbir zaman
  /// akışı bloke etmez).
  Future<NormalizedLabel?> normalize(String text, {String? lang}) async {
    if (!isConfigured) return null;
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/v1/normalize-label'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text, 'lang': ?lang}),
          )
          .timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) return null;
      return NormalizedLabel.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
