import '../../data/models/prayer_time_model.dart';

class NextPrayerInfo {
  final String name;
  final DateTime time;

  NextPrayerInfo(this.name, this.time);
}

class PrayerUtils {
  static NextPrayerInfo getNextPrayer(PrayerTimes times) {
    final now = DateTime.now();

    final schedule = {
      'Fajr': _parse(times.fajr),
      'Dhuhr': _parse(times.dhuhr),
      'Asr': _parse(times.asr),
      'Maghrib': _parse(times.maghrib),
      'Isha': _parse(times.isha),
    };

    for (final entry in schedule.entries) {
      if (entry.value.isAfter(now)) {
        return NextPrayerInfo(entry.key, entry.value);
      }
    }

    // After Isha → next day's Fajr
    final fajrTomorrow = _parse(times.fajr).add(const Duration(days: 1));
    return NextPrayerInfo('Fajr', fajrTomorrow);
  }

  static DateTime _parse(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
