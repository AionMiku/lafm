import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class CalendarDayCell extends StatelessWidget {

  final HijriCalendar day;
  final VoidCallback? onLongPress;

  const CalendarDayCell({super.key, required this.day, this.onLongPress});

  @override
  Widget build(BuildContext context) {

    final now = HijriCalendar.now();

    final isToday =
        day.hDay == now.hDay &&
        day.hMonth == now.hMonth &&
        day.hYear == now.hYear;

    return InkWell(
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.all(4),

        decoration: BoxDecoration(
          color: isToday ? const Color(0xFF5FB878) : null,
          borderRadius: BorderRadius.circular(6),
        ),

        child: Center(
          child: Text(
            "${day.hDay}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isToday ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}