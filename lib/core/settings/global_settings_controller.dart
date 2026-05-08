import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsController extends ChangeNotifier {
  // =====================
  // CONSTANTS
  // =====================

  static const double _minScale = 0.9;
  static const double _maxScale = 1.4;

  static const String _kBaseScale = 'baseScale';
  static const String _kArabicScale = 'arabicScale';
  static const String _kTranslationScale = 'translationScale';
  static const String _kTransliterationScale = 'transliterationScale';
  static const String _kShowTranslation = 'showTranslation';
  static const String _kShowTransliteration = 'showTransliteration';
  static const String _kPrayerTimerStyle = 'prayerTimerStyle';
  static const String _kIsFirstLaunch = 'isFirstLaunch';
  static const String _kIsArabicOnlyMode = 'isArabicOnlyMode';

  // =====================
  // STATE
  // =====================

  late double _baseScale;
  late double _arabicScale;
  late double _translationScale;
  late double _transliterationScale;

  bool _showTranslation = true;
  bool _showTransliteration = true;
  String _prayerTimerStyle = 'square';
  bool _isFirstLaunch = true;
  bool _isArabicOnlyMode = false;

  bool _initialized = false;

  // =====================
  // GETTERS
  // =====================

  double get baseScale => _baseScale;
  double get arabicScale => _arabicScale;
  double get translationScale => _translationScale;
  double get transliterationScale => _transliterationScale;

  bool get showTranslation => _showTranslation;
  bool get showTransliteration => _showTransliteration;
  String get prayerTimerStyle => _prayerTimerStyle;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isArabicOnlyMode => _isArabicOnlyMode;

  bool get isReady => _initialized;

  // =====================
  // INIT
  // =====================

  GlobalSettingsController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // Default = min + 5%
    final double defaultScale = _minScale + ((_maxScale - _minScale) * 0.05);

    _baseScale = prefs.getDouble(_kBaseScale) ?? defaultScale;
    _arabicScale = prefs.getDouble(_kArabicScale) ?? 1.0;
    _translationScale = prefs.getDouble(_kTranslationScale) ?? 1.0;
    _transliterationScale = prefs.getDouble(_kTransliterationScale) ?? 1.0;

    _showTranslation = prefs.getBool(_kShowTranslation) ?? true;
    _showTransliteration = prefs.getBool(_kShowTransliteration) ?? true;
    _prayerTimerStyle = prefs.getString(_kPrayerTimerStyle) ?? 'square';
    _isFirstLaunch = prefs.getBool(_kIsFirstLaunch) ?? true;
    _isArabicOnlyMode = prefs.getBool(_kIsArabicOnlyMode) ?? false;

    _initialized = true;
    notifyListeners();
  }

  // =====================
  // SETTERS (AUTO SAVE)
  // =====================

  Future<void> _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) await prefs.setDouble(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  void setBaseScale(double value) {
    _baseScale = value;
    _save(_kBaseScale, value);
    notifyListeners();
  }

  void setArabicScale(double value) {
    _arabicScale = value;
    _save(_kArabicScale, value);
    notifyListeners();
  }

  void setTranslationScale(double value) {
    _translationScale = value;
    _save(_kTranslationScale, value);
    notifyListeners();
  }

  void setTransliterationScale(double value) {
    _transliterationScale = value;
    _save(_kTransliterationScale, value);
    notifyListeners();
  }

  void toggleTranslation(bool value) {
    _showTranslation = value;
    _save(_kShowTranslation, value);
    notifyListeners();
  }

  void toggleTransliteration(bool value) {
    _showTransliteration = value;
    _save(_kShowTransliteration, value);
    notifyListeners();
  }

  void setPrayerTimerStyle(String val) async {
    _prayerTimerStyle = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrayerTimerStyle, val);
    notifyListeners();
  }

  void completeOnboarding() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsFirstLaunch, false);
    notifyListeners();
  }

  void toggleArabicOnlyMode() async {
    _isArabicOnlyMode = !_isArabicOnlyMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsArabicOnlyMode, _isArabicOnlyMode);
    
    // Automatically force translation bindings off when in pure Arabic mode
    if (_isArabicOnlyMode) {
      _showTranslation = false;
      _showTransliteration = false;
      await prefs.setBool(_kShowTranslation, false);
      await prefs.setBool(_kShowTransliteration, false);
    }
    notifyListeners();
  }

  // =====================
  // SLIDER BOUNDS
  // =====================

  double get minScale => _minScale;
  double get maxScale => _maxScale;
}
