import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Uygulama geneli görünüm ayarları: dil ve yazı boyutu.
///
/// Tekil (singleton) ChangeNotifier'dır; MaterialApp bunu dinler, ayar
/// değişince tüm uygulama anında yeni dil/boyutla yeniden çizilir.
/// `locale == null` → sistem dili (varsayılan).
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _langKey = 'app_language';
  static const _scaleKey = 'text_scale';

  static const minScale = 0.85;
  static const maxScale = 1.4;

  Locale? _locale;
  double _textScale = 1.0;

  Locale? get locale => _locale;
  double get textScale => _textScale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_langKey);
    if (code != null && S.supported.contains(code)) _locale = Locale(code);
    final scale = prefs.getDouble(_scaleKey);
    if (scale != null) _textScale = scale.clamp(minScale, maxScale);
    notifyListeners();
  }

  /// `code == null` → sistem diline dön.
  Future<void> setLanguage(String? code) async {
    _locale = code == null ? null : Locale(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_langKey);
    } else {
      await prefs.setString(_langKey, code);
    }
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale.clamp(minScale, maxScale);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_scaleKey, _textScale);
  }
}
