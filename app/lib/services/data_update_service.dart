import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'knowledge_base.dart';
import 'normalize_api.dart';
import 'off_config.dart';

/// Havadan (OTA) veri güncellemesi: E-kod tablosu + içindekiler sözlüğü,
/// mağaza onayı beklemeden backend'den güncellenebilir. "Sıfır hata"
/// hedefinin operasyonel ayağı — tabloda hata bulunursa düzeltme saatler
/// içinde tüm kullanıcılara iner.
///
/// Güvenlik çitleri (bozuk/eski veri asla yüklenmez):
///  * İndirilen veri önce parse edilir; parse edilemeyen atılır.
///  * Sürüm, gömülü/önbellekteki sürümden YENİ olmalı (downgrade koruması).
///  * Kayıt sayısı azalamaz (kırpılmış tablo koruması).
///  * Backend tanımsızsa veya erişilemezse sessizce gömülü veri kullanılır.
class DataUpdateService {
  static const _ecodesFile = 'ota_e_codes.json';
  static const _ingredientsFile = 'ota_ingredients.json';

  /// "0.3.1" > "0.3.0" — parça parça sayısal karşılaştırma.
  /// a > b → pozitif, eşit → 0.
  static int compareVersions(String a, String b) {
    final pa = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final pb = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x - y;
    }
    return 0;
  }

  /// İndirilen çiftin mevcut (gömülü ya da önbellek) çifte göre kabul
  /// edilebilirliği: parse + daha yeni sürüm + kayıt sayısı azalmıyor.
  static bool isAcceptable({
    required String newEcodes,
    required String newIngredients,
    required KnowledgeBase current,
  }) {
    final KnowledgeBase candidate;
    try {
      candidate = KnowledgeBase.fromJsonStrings(newEcodes, newIngredients);
    } catch (_) {
      return false;
    }
    if (compareVersions(candidate.version, current.version) <= 0) return false;
    if (candidate.ecodes.length < current.ecodes.length) return false;
    if (candidate.ingredients.length < current.ingredients.length) return false;
    return true;
  }

  /// En iyi bilgi tabanını yükler: geçerli bir OTA önbelleği varsa ve gömülüden
  /// yeniyse onu, değilse gömülüyü. Önbellek bozuksa silinir.
  static Future<KnowledgeBase> loadKnowledgeBase() async {
    final bundled = await KnowledgeBase.loadFromAssets();
    try {
      final dir = await getApplicationSupportDirectory();
      final e = File('${dir.path}/$_ecodesFile');
      final i = File('${dir.path}/$_ingredientsFile');
      if (!e.existsSync() || !i.existsSync()) return bundled;
      final es = await e.readAsString();
      final is_ = await i.readAsString();
      if (isAcceptable(newEcodes: es, newIngredients: is_, current: bundled)) {
        return KnowledgeBase.fromJsonStrings(es, is_);
      }
      // Gömülü artık daha yeni (uygulama güncellendi) ya da önbellek bozuk.
      e.deleteSync();
      i.deleteSync();
    } catch (_) {
      // Dosya sistemi hatası veri akışını asla bloke etmez.
    }
    return bundled;
  }

  /// Backend'den güncel veri çiftini dener; kabul edilirse kaydeder ve yeni
  /// bilgi tabanını döndürür (çağıran hot-swap yapar). Aksi halde null.
  static Future<KnowledgeBase?> checkForUpdate(KnowledgeBase current) async {
    if (!NormalizeApi.isConfigured) return null;
    try {
      final resp = await http
          .get(
            Uri.parse('${NormalizeApi.baseUrl}/v1/data'),
            headers: {'User-Agent': OffConfig.userAgent},
          )
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return null;
      final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final es = jsonEncode(body['e_codes']);
      final is_ = jsonEncode(body['ingredients']);
      if (!isAcceptable(newEcodes: es, newIngredients: is_, current: current)) {
        return null;
      }
      final dir = await getApplicationSupportDirectory();
      await File('${dir.path}/$_ecodesFile').writeAsString(es);
      await File('${dir.path}/$_ingredientsFile').writeAsString(is_);
      return KnowledgeBase.fromJsonStrings(es, is_);
    } catch (_) {
      return null;
    }
  }
}
