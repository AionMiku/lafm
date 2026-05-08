import 'package:hijri/hijri_calendar.dart';

class HijriCalendarService {

  static List<HijriCalendar> getMonthDays(int year, int month) {

    List<HijriCalendar> days = [];

    for (int i = 1; i <= 30; i++) {

      try {

        final day = HijriCalendar()
          ..hYear = year
          ..hMonth = month
          ..hDay = i;

        days.add(day);

      } catch (_) {
        break;
      }
    }

    return days;
  }
}