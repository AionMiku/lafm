import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerSettingsProvider extends ChangeNotifier {
  bool _enableAll = true;
  bool _isReady = false;

  final Map<String, Map<String, dynamic>> _prayers = {
    'Fajr': {'enabled': true, 'sound': 'Sound 1'},
    'Sunrise': {'enabled': false, 'sound': 'Silent'},
    'Dhuhr': {'enabled': true, 'sound': 'Sound 1'},
    'Asr': {'enabled': true, 'sound': 'Sound 1'},
    'Maghrib': {'enabled': true, 'sound': 'Sound 1'},
    'Isha': {'enabled': true, 'sound': 'Sound 1'},
  };

  bool get enableAll => _enableAll;
  bool get isReady => _isReady;

  Map<String, dynamic> getPrayerSettings(String prayer) {
    return _prayers[prayer] ?? {'enabled': true, 'sound': 'Sound 1'};
  }

  PrayerSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _enableAll = prefs.getBool('prayer_enable_all') ?? true;

    for (var key in _prayers.keys) {
      _prayers[key]!['enabled'] = prefs.getBool('prayer_${key}_enabled') ?? _prayers[key]!['enabled'];
      _prayers[key]!['sound'] = prefs.getString('prayer_${key}_sound') ?? _prayers[key]!['sound'];
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> toggleMaster(bool value) async {
    _enableAll = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_enable_all', value);

    for (var key in _prayers.keys) {
      _prayers[key]!['enabled'] = value;
      await prefs.setBool('prayer_${key}_enabled', value);
    }
    notifyListeners();
  }

  Future<void> togglePrayer(String prayer, bool value) async {
    if (!_prayers.containsKey(prayer)) return;

    _prayers[prayer]!['enabled'] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_${prayer}_enabled', value);

    if (!value) {
      _enableAll = false;
      await prefs.setBool('prayer_enable_all', false);
    } else {
      bool allOn = _prayers.values.every((p) => p['enabled'] == true);
      if (allOn) {
        _enableAll = true;
        await prefs.setBool('prayer_enable_all', true);
      }
    }
    notifyListeners();
  }

  Future<void> toggleSound(String prayer) async {
    if (!_prayers.containsKey(prayer)) return;
    
    final currentSound = _prayers[prayer]!['sound'];
    final newSound = currentSound == 'Sound 1' ? 'Silent' : 'Sound 1';
    
    _prayers[prayer]!['sound'] = newSound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayer_${prayer}_sound', newSound);
    
    notifyListeners();
  }

  // Common UI helpers for consistent icons/colors across the app
  static IconData getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Icons.wb_twilight; // sunrise
      case 'Sunrise':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny; // sun
      case 'Asr':
        return Icons.wb_sunny_outlined; // afternoon sun
      case 'Maghrib':
        return Icons.brightness_4; // sunset / half moon
      case 'Isha':
        return Icons.nightlight_round; // night mode moon
      default:
        return Icons.access_time;
    }
  }

  static Color getPrayerIconColor(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return const Color(0xFF1E88E5); // slightly darker sunrise blue
      case 'Sunrise':
        return const Color(0xFF1E88E5); 
      case 'Dhuhr':
        return const Color(0xFFFBC02D); // richer golden yellow
      case 'Asr':
        return const Color(0xFFF57C00); // richer orange
      case 'Maghrib':
        return const Color(0xFFD84315); // reddish-orange
      case 'Isha':
        return const Color(0xFF5E35B1); // deeper purple/blue
      default:
        return Colors.greenAccent;
    }
  }

  static Color getPrayerIconBgColor(String prayerName) {
    // Generate a matching translucent background based on the foreground color
    return getPrayerIconColor(prayerName).withValues(alpha: 0.2);
  }
}
