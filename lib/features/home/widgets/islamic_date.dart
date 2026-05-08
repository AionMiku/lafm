import 'package:flutter/material.dart';
import '../../calendar/screens/islamic_calendar_screen.dart';

import 'package:hijri/hijri_calendar.dart';

class IslamicDate extends StatelessWidget {
  const IslamicDate({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate real-time Islamic Date synchronized exactly with the Calendar Screen's spelling
    final today = HijriCalendar.now();
    final dateString = '${hijriMonths[today.hMonth - 1]} ${today.hDay}, ${today.hYear} AH';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const IslamicCalendarScreen(),
          ),
        );
      },

      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          dateString,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}