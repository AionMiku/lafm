class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    this.sunrise = "06:00 (EST)",
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // API response
    if (json.containsKey('data')) {
      final timings = json['data']['timings'];
      return PrayerTimes(
        fajr: timings['Fajr'],
        sunrise: timings['Sunrise'] ?? '06:00',
        dhuhr: timings['Dhuhr'],
        asr: timings['Asr'],
        maghrib: timings['Maghrib'],
        isha: timings['Isha'],
      );
    }

    // Cached JSON
    return PrayerTimes(
      fajr: json['fajr'],
      sunrise: json['sunrise'] ?? '06:00',
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }
}
