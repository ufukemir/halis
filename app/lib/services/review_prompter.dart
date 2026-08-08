import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mağaza değerlendirme isteği: kullanıcı değeri gördükten SONRA (5. başarılı
/// ürün sonucu) sistem puanlama penceresi bir kez istenir. Asla tekrarlamaz,
/// asla akışı bloke etmez — sistem penceresi zaten işletim sistemince
/// sıklık-sınırlıdır.
class ReviewPrompter {
  static const _countKey = 'review_scan_count';
  static const _askedKey = 'review_asked';
  static const _threshold = 5;

  static Future<void> onSuccessfulScan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_askedKey) ?? false) return;
      final count = (prefs.getInt(_countKey) ?? 0) + 1;
      await prefs.setInt(_countKey, count);
      if (count < _threshold) return;
      await prefs.setBool(_askedKey, true);
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (_) {
      // Değerlendirme isteği hiçbir akışı bozamaz.
    }
  }
}
