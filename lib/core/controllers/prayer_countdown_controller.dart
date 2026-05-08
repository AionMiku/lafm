import 'dart:async';
import '../services/storage_service.dart';
import '../utils/prayer_utils.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerCountdownData {
  final String nextPrayer;
  final Duration remaining;
  final double dayProgress; // 0.0 → 1.0

  PrayerCountdownData({
    required this.nextPrayer,
    required this.remaining,
    required this.dayProgress,
  });
}

class PrayerCountdownController {
  final _storage = StorageService();
  Timer? _timer;

  void start(void Function(PrayerCountdownData) onUpdate) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final PrayerTimes? times = await _storage.getCachedPrayerTimes();
      
      if (times == null) {
        onUpdate(
          PrayerCountdownData(
            nextPrayer: '',
            remaining: Duration.zero,
            dayProgress: 0.0,
          ),
        );
        return;
      }

      final now = DateTime.now();

      // 24h progress
      final midnight =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dayProgress =
          1 - midnight.difference(now).inSeconds / 86400;

      // Next prayer
      final next = PrayerUtils.getNextPrayer(times);
      final remaining = next.time.difference(now);

      onUpdate(
        PrayerCountdownData(
          nextPrayer: next.name,
          remaining: remaining,
          dayProgress: dayProgress.clamp(0.0, 1.0),
        ),
      );
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
