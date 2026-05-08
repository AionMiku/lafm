import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _kPrimaryColor = 'primaryColor';
  static const String _kGlassOpacity = 'glassOpacity';

  // We are locked to the Nordic Glassmorphism theme, so mode is implicitly handled,
  // but we keep the variable for structural integrity.
  ThemeMode _themeMode = ThemeMode.light;
  
  // Default to the Midnight Nordic Teal accent
  Color _primaryColor = const Color(0xFF6CFCE3); 
  
  // Default to 4% glass opacity
  double _glassOpacity = 0.04; 

  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  double get glassOpacity => _glassOpacity;
  bool get isReady => _initialized;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeController() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedColor = prefs.getInt(_kPrimaryColor);
    if (savedColor != null) {
      _primaryColor = Color(savedColor);
    }

    final savedOpacity = prefs.getDouble(_kGlassOpacity);
    if (savedOpacity != null) {
      _glassOpacity = savedOpacity;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;

    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrimaryColor, color.value);
    notifyListeners();
  }

  Future<void> setGlassOpacity(double opacity) async {
    if (_glassOpacity == opacity) return;

    _glassOpacity = opacity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kGlassOpacity, opacity);
    notifyListeners();
  }
}
