import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abonelik + kota yönetimi.
///
/// İlkeler (docs/03):
///  * Barkod tarama HERKESE sınırsız ve ücretsizdir (yerel kural motoru).
///  * Etiket/AI analizi ücretsiz katmanda ayda [freeLabelQuota] ile sınırlıdır;
///    premium'da sınırsızdır.
///  * RevenueCat anahtarı `--dart-define=REVENUECAT_API_KEY=...` ile verilir;
///    verilmemişse servis çevrimdışı moddadır (çökmek yok, premium=false).
class PremiumService {
  static const _apiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const entitlementId = 'premium';
  static const freeLabelQuota = 10;

  static bool _configured = false;

  static Future<void> init() async {
    if (_apiKey.isEmpty) return; // Çevrimdışı mod (geliştirme / anahtar öncesi)
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _configured = true;
    } catch (_) {
      _configured = false;
    }
  }

  static Future<bool> isPremium() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }

  /// Ay anahtarı: "2026-08" — kota her ay kendiliğinden sıfırlanır.
  static String get _monthKey {
    final now = DateTime.now();
    return 'label_quota_${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static Future<int> usedLabelAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_monthKey) ?? 0;
  }

  static Future<bool> canAnalyzeLabel() async {
    if (await isPremium()) return true;
    return (await usedLabelAnalyses()) < freeLabelQuota;
  }

  static Future<void> recordLabelAnalysis() async {
    if (await isPremium()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_monthKey, (prefs.getInt(_monthKey) ?? 0) + 1);
  }

  static Future<int> remainingLabelAnalyses() async {
    final used = await usedLabelAnalyses();
    return (freeLabelQuota - used).clamp(0, freeLabelQuota);
  }

  static bool get storeConfigured => _configured;

  /// Aktif teklifteki yıllık paket (fiyat gösterimi + satın alma).
  static Future<Package?> currentPackage() async {
    if (!_configured) return null;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current?.annual ?? current?.availablePackages.firstOrNull;
    } catch (_) {
      return null;
    }
  }

  /// true → premium etkin. Kullanıcı iptali dahil her hatada false döner.
  static Future<bool> purchase(Package package) async {
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      return await isPremium();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restore() async {
    if (!_configured) return false;
    try {
      await Purchases.restorePurchases();
      return await isPremium();
    } catch (_) {
      return false;
    }
  }
}
