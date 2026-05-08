import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/prayer_time_model.dart';

class PrayerService {
  Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final url =
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PrayerTimes.fromJson(jsonData);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
