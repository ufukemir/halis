import 'dart:convert';

import 'package:http/http.dart' as http;

/// Open Food Facts katkı istemcisi (MVP md.7).
///
/// "Ürün bulunamadı" akışında kullanıcının çektiği etiket fotoğrafını OFF'a
/// yükler — Türkiye kapsam açığını kullanıcı katkısı kapatır. Yükleme daima
/// açık kullanıcı onayıyla yapılır: fotoğraf ODbL lisansıyla kamuya açılır.
///
/// Kimlik, uygulamaya ait OFF hesabıdır ve derleme zamanında verilir:
///   flutter run --dart-define=OFF_USER_ID=... --dart-define=OFF_PASSWORD=...
/// Tanımsızsa katkı akışı kapalıdır (arayüzde hiç gösterilmez).
class OffContribution {
  static const _userId = String.fromEnvironment('OFF_USER_ID');
  static const _password = String.fromEnvironment('OFF_PASSWORD');
  static const _host = 'world.openfoodfacts.org';

  static bool get isConfigured => _userId.isNotEmpty && _password.isNotEmpty;

  final http.Client _client;

  OffContribution([http.Client? client]) : _client = client ?? http.Client();

  /// İçindekiler fotoğrafını barkoda ekler; başarıda true.
  /// Ağ/servis hatasında sessizce false döner — katkı hiçbir akışı bloke etmez.
  Future<bool> uploadIngredientsPhoto({
    required String barcode,
    required String imagePath,
    String lang = 'tr',
  }) async {
    if (!isConfigured) return false;
    try {
      final field = 'ingredients_$lang';
      final req = http.MultipartRequest(
        'POST',
        Uri.https(_host, '/cgi/product_image_upload.pl'),
      )
        ..headers['User-Agent'] = 'Halis/0.1 (halal scanner; dev build)'
        ..fields['code'] = barcode
        ..fields['imagefield'] = field
        ..fields['user_id'] = _userId
        ..fields['password'] = _password
        ..files.add(await http.MultipartFile.fromPath('imgupload_$field', imagePath));
      final streamed = await _client.send(req).timeout(const Duration(seconds: 60));
      if (streamed.statusCode != 200) return false;
      return isUploadOk(await streamed.stream.bytesToString());
    } catch (_) {
      return false;
    }
  }

  /// OFF yanıtı başarı mı? Yanıt JSON'unda `status: "status ok"` beklenir.
  static bool isUploadOk(String body) {
    try {
      final j = jsonDecode(body) as Map<String, dynamic>;
      return j['status'] == 'status ok';
    } catch (_) {
      return false;
    }
  }
}
