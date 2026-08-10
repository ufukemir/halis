import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ödüllü reklam katmanı: ücretsiz kullanıcıda 1 reklam = 1 barkod tarama
/// kredisi. Premium kullanıcı bu katmana hiç uğramaz (main.dart karar verir).
///
/// Tasarım ilkeleri:
///  * ASLA akışı kilitleme: reklam yüklenemediyse (ağ yok, envanter yok,
///    AdMob yapılandırılmamış) tarama ÜCRETSİZ devam eder (fail-open).
///    Mağaza incelemesi ve çevrimdışı senaryolar için şart.
///  * Kimlik/izin gerektirmesin diye istekler kişiselleştirilmemiş (npa).
///    (AB için UMP onay akışı yayın öncesi eklenecek — docs/04 notu.)
///  * Gerçek reklam kimlikleri --dart-define ile verilir; verilmezse
///    Google'ın resmî TEST kimlikleri kullanılır (gelir üretmez, politika
///    ihlali olmaz).
class AdService {
  static const _androidUnit = String.fromEnvironment(
    'ADMOB_REWARDED_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // Google TEST
  );
  static const _iosUnit = String.fromEnvironment(
    'ADMOB_REWARDED_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313', // Google TEST
  );

  static bool _initialized = false;
  static RewardedAd? _loaded;

  static String get _unitId => Platform.isAndroid ? _androidUnit : _iosUnit;

  /// Uygulama açılışında çağrılır; ilk reklamı arka planda ısıtır.
  /// Hata durumunda sessizce vazgeçer (uygulama reklamsız da çalışır).
  static Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _preload();
    } catch (_) {
      // Reklam SDK'sı yoksa/başlayamadıysa uygulama etkilenmez.
    }
  }

  static void _preload() {
    if (!_initialized || _loaded != null) return;
    RewardedAd.load(
      adUnitId: _unitId,
      request: const AdRequest(nonPersonalizedAds: true),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _loaded = ad,
        onAdFailedToLoad: (_) => _loaded = null,
      ),
    );
  }

  /// Ödüllü reklamı gösterir; kullanıcı ödülü hak ettiyse true döner.
  /// Reklam hazır değilse true döner (fail-open) ve arkada yenisi ısıtılır.
  static Future<bool> showRewardedAd() async {
    final ad = _loaded;
    if (ad == null) {
      _preload();
      return true; // Kilitleme yok: reklam yoksa tarama yine de çalışır.
    }
    _loaded = null;
    var rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        rewarded = true; // Gösterim hatası kullanıcının suçu değil.
      },
    );
    try {
      await ad.show(onUserEarnedReward: (_, _) => rewarded = true);
      // show() reklam kapanana kadar değil, gösterim başlarken döner;
      // ödül callback'inin işlenmesi için kapanışı bekleyen küçük bir
      // gecikme yerine dismiss callback'ine güveniyoruz: pratikte
      // onUserEarnedReward kapanıştan önce tetiklenir.
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (_) {
      rewarded = true;
    }
    _preload();
    return rewarded;
  }
}

/// Tarama kredisi: her barkod tarama 1 kredi harcar, her ödüllü reklam
/// 1 kredi kazandırır. İlk kurulumda küçük bir hoş geldin paketi verilir
/// (kullanıcı reklam görmeden uygulamanın değerini görsün).
class ScanCreditService {
  static const _key = 'scan_credits_v1';
  static const _seededKey = 'scan_credits_seeded_v1';
  static const welcomeCredits = 5;

  Future<int> balance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_seededKey) ?? false)) {
      await prefs.setBool(_seededKey, true);
      await prefs.setInt(_key, welcomeCredits);
      return welcomeCredits;
    }
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> grant([int n = 1]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, (prefs.getInt(_key) ?? 0) + n);
  }

  /// Kredi varsa düşer ve true döner; yoksa false.
  Future<bool> consume() async {
    final current = await balance();
    if (current <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, current - 1);
    return true;
  }
}
