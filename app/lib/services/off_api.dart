import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'off_config.dart';

/// Open Food Facts istemcisi.
///
/// ODbL notu: OFF verisi canlı sorgulanır ve kendi hüküm veritabanımızla
/// KALICI olarak birleştirilmez (share-alike yükümlülüğü tetiklenmesin diye).
/// Uygulama içinde OFF'a atıf gösterilir.
class OffApi {
  static const _host = 'world.openfoodfacts.org';
  static const _fields =
      'product_name,brands,ingredients_text,ingredients_text_tr,ingredients_text_en,ingredients_text_de,additives_tags,ingredients_analysis_tags,image_front_small_url';

  final http.Client _client;

  OffApi([http.Client? client]) : _client = client ?? http.Client();

  /// Barkodla ürün getirir; bulunamazsa null döner.
  Future<OffProduct?> fetchProduct(String barcode) async {
    final uri = Uri.https(_host, '/api/v2/product/$barcode.json', {'fields': _fields});
    final res = await _client.get(uri, headers: {
      'User-Agent': OffConfig.userAgent,
    });
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw OffApiException('OFF ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['status'] == 0 || body['product'] == null) return null;
    final p = body['product'] as Map<String, dynamic>;

    final analysisTags = List<String>.from(p['ingredients_analysis_tags'] as List? ?? []);
    String? vegan;
    if (analysisTags.contains('en:vegan')) vegan = 'yes';
    if (analysisTags.contains('en:non-vegan')) vegan = 'no';
    if (analysisTags.contains('en:maybe-vegan')) vegan = 'maybe';

    return OffProduct(
      barcode: barcode,
      name: p['product_name'] as String?,
      brands: p['brands'] as String?,
      // Türkçe etiket varsa onu tercih et; yoksa genel alan.
      ingredientsText: (p['ingredients_text_tr'] as String?)?.trim().isNotEmpty == true
          ? p['ingredients_text_tr'] as String
          : (p['ingredients_text'] as String? ??
              p['ingredients_text_en'] as String? ??
              p['ingredients_text_de'] as String?),
      additiveTags: List<String>.from(p['additives_tags'] as List? ?? []),
      veganStatus: vegan,
      imageUrl: p['image_front_small_url'] as String?,
    );
  }
}

class OffApiException implements Exception {
  final String message;
  OffApiException(this.message);
  @override
  String toString() => 'OffApiException: $message';
}
