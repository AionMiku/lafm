import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/prayer_time_model.dart';

class StorageService {
  static const _prayerKey = 'cached_prayer_times';
  static const _dateKey = 'cached_prayer_date';

  Future<void> savePrayerTimes(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(_prayerKey, jsonEncode(times.toJson()));
    prefs.setString(_dateKey, DateTime.now().toIso8601String());
  }

  Future<PrayerTimes?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_prayerKey);
    final date = prefs.getString(_dateKey);

    if (data == null || date == null) return null;

    final cachedDate = DateTime.parse(date);
    final now = DateTime.now();

    // invalidate cache after midnight
    if (cachedDate.day != now.day ||
        cachedDate.month != now.month ||
        cachedDate.year != now.year) {
      return null;
    }

    return PrayerTimes.fromJson(jsonDecode(data));
  }
}
