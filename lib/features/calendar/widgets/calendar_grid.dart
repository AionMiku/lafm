import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {

  final List<HijriCalendar> days;
  final void Function(HijriCalendar)? onDayLongPressed;

  const CalendarGrid({
    super.key,
    required this.days,
    this.onDayLongPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        /// Week names
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text("Sun"),
            Text("Mon"),
            Text("Tue"),
            Text("Wed"),
            Text("Thu"),
            Text("Fri"),
            Text("Sat"),
          ],
        ),

        const SizedBox(height: 8),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {

              final day = days[index];

              return CalendarDayCell(
                day: day,
                onLongPress: onDayLongPressed != null 
                    ? () => onDayLongPressed!(day) 
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}