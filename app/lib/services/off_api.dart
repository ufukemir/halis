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
      'product_name,brands,ingredients_text,ingredients_text_tr,ingredients_text_en,ingredients_text_de,additives_tags,ingredients_analysis_tags,image_front_small_url,categories_tags,allergens_tags';

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

    return _productFromJson(barcode, p, vegan);
  }

  /// Barkodsuz isim araması — hafif sonuç listesi döndürür.
  ///
  /// [countryCode] verilirse önce o ülkenin OFF alt alanı sorgulanır
  /// (kullanıcının rafındaki ürünler öne gelir), dünya sonuçları arkasına
  /// eklenir (barkoda göre tekilleştirilir). [page] 1'den başlar (sayfalama).
  Future<List<OffSearchHit>> searchByName(
    String query, {
    int pageSize = 12,
    int page = 1,
    String? countryCode,
  }) async {
    final world = _searchHost(_host, query, pageSize, page);
    if (countryCode == null || countryCode.isEmpty) return world;
    List<OffSearchHit> local;
    try {
      local = await _searchHost('$countryCode.openfoodfacts.org', query, pageSize, page);
    } catch (_) {
      local = const []; // ülke alt alanı hatası dünya aramasını engellemesin
    }
    final seen = {for (final h in local) h.barcode};
    return [
      ...local,
      for (final h in await world)
        if (!seen.contains(h.barcode)) h,
    ];
  }

  Future<List<OffSearchHit>> _searchHost(
      String host, String query, int pageSize, int page) async {
    final uri = Uri.https(host, '/cgi/search.pl', {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$pageSize',
      'page': '$page',
      'fields': 'code,product_name,brands,image_front_small_url',
    });
    final res = await _client.get(uri, headers: {'User-Agent': OffConfig.userAgent});
    if (res.statusCode != 200) throw OffApiException('OFF ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return [
      for (final p in (body['products'] as List? ?? []))
        if ((p as Map<String, dynamic>)['code'] is String && (p['code'] as String).isNotEmpty)
          OffSearchHit(
            barcode: p['code'] as String,
            name: p['product_name'] as String?,
            brands: p['brands'] as String?,
            imageUrl: p['image_front_small_url'] as String?,
          ),
    ];
  }

  /// Kategori içi ürünler (alternatif önerisi adayları) — içerik verisiyle
  /// birlikte gelir ki her aday yerel kural motorundan geçirilebilsin.
  Future<List<OffProduct>> fetchCategoryProducts(String categoryTag, {int pageSize = 24}) async {
    final uri = Uri.https(_host, '/api/v2/search', {
      'categories_tags': categoryTag,
      'page_size': '$pageSize',
      'fields': 'code,$_fields',
    });
    final res = await _client.get(uri, headers: {'User-Agent': OffConfig.userAgent});
    if (res.statusCode != 200) throw OffApiException('OFF ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return [
      for (final p in (body['products'] as List? ?? []))
        if ((p as Map<String, dynamic>)['code'] is String && (p['code'] as String).isNotEmpty)
          _productFromJson(p['code'] as String, p, _veganFrom(p)),
    ];
  }

  static String? _veganFrom(Map<String, dynamic> p) {
    final tags = List<String>.from(p['ingredients_analysis_tags'] as List? ?? []);
    if (tags.contains('en:vegan')) return 'yes';
    if (tags.contains('en:non-vegan')) return 'no';
    if (tags.contains('en:maybe-vegan')) return 'maybe';
    return null;
  }

  static OffProduct _productFromJson(String barcode, Map<String, dynamic> p, String? vegan) {
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
      categoryTags: List<String>.from(p['categories_tags'] as List? ?? []),
      allergenTags: List<String>.from(p['allergens_tags'] as List? ?? []),
      vegetarianStatus: _vegetarianFrom(p),
      tracesTags: List<String>.from(p['traces_tags'] as List? ?? []),
      palmOilStatus: _palmOilFrom(p),
    );
  }

  static String? _vegetarianFrom(Map<String, dynamic> p) {
    final tags = List<String>.from(p['ingredients_analysis_tags'] as List? ?? []);
    if (tags.contains('en:vegetarian')) return 'yes';
    if (tags.contains('en:non-vegetarian')) return 'no';
    if (tags.contains('en:maybe-vegetarian')) return 'maybe';
    return null;
  }

  static String? _palmOilFrom(Map<String, dynamic> p) {
    final tags = List<String>.from(p['ingredients_analysis_tags'] as List? ?? []);
    if (tags.contains('en:palm-oil')) return 'yes';
    if (tags.contains('en:palm-oil-free')) return 'no';
    if (tags.contains('en:may-contain-palm-oil')) return 'maybe';
    return null;
  }
}

class OffApiException implements Exception {
  final String message;
  OffApiException(this.message);
  @override
  String toString() => 'OffApiException: $message';
}
