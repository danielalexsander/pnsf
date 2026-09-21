import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências globais do app (tema e tamanho da letra), persistidas em disco.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _keyDarkMode = 'dark_mode';
  static const _keyFontScale = 'font_scale';
  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.6;

  bool _darkMode = false;
  double _fontScale = 1.0;

  bool get darkMode => _darkMode;
  double get fontScale => _fontScale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_keyDarkMode) ?? false;
    _fontScale = prefs.getDouble(_keyFontScale) ?? 1.0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<void> setFontScale(double value) async {
    _fontScale = value.clamp(minFontScale, maxFontScale);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, _fontScale);
  }
}
