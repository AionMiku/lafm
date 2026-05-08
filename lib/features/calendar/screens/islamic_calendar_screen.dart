import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../services/hijri_calendar_service.dart';
import '../widgets/calendar_grid.dart';

const List<String> hijriMonths = [
  "Muharram",
  "Safar",
  "Rabi al-Awwal",
  "Rabi al-Thani",
  "Jumada al-Ula",
  "Jumada al-Akhirah",
  "Rajab",
  "Sha'ban",
  "Ramadan",
  "Shawwal",
  "Dhu al-Qadah",
  "Dhu al-Hijjah",
];

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  late HijriCalendar today;
  late HijriCalendar _currentViewedMonth;
  final PageController _pageController = PageController(initialPage: 500);

  // Simple state memory for user events (In production, use SQLite/SharedPreferences)
  final List<Map<String, dynamic>> _userEvents = [];

  // Birthday calculator state
  DateTime? _gregorianBday;
  HijriCalendar? _hijriBday;

  @override
  void initState() {
    super.initState();
    today = HijriCalendar.now();
    _currentViewedMonth = _monthFromPage(500);
  }

  HijriCalendar _monthFromPage(int page) {
    final base = HijriCalendar.now();
    int offset = page - 500;
    int month = base.hMonth + offset;
    int year = base.hYear;

    while (month > 12) {
      month -= 12;
      year++;
    }
    while (month < 1) {
      month += 12;
      year--;
    }

    final result = HijriCalendar();
    result.hYear = year;
    result.hMonth = month;
    result.hDay = 1;
    return result;
  }

  Map<String, dynamic> _getMonthInfo(int month) {
    const info = {
      1: "The month of Muharram is the first month of the Islamic calendar and one of the four sacred months. Fasting on Ashura is highly recommended.",
      2: "Safar is the second month of the lunar calendar. It is a time for continued devotion and reflection.",
      3: "Rabi al-Awwal is highly significant as it marks the birth of Prophet Muhammad (PBUH) and is often a time for reflection on his life.",
      4: "Rabi al-Thani marks a peaceful part of the year for establishing steadfast spiritual routines.",
      5: "Jumada al-Ula is a month of perseverance, historically marking the change of seasons in early Arabia.",
      6: "Jumada al-Akhirah continues daily religious life smoothly heading towards the sacred months.",
      7: "Rajab is a sacred month of peace and spiritual preparation. The miraculous Night Journey (Isra and Mi'raj) took place in this month.",
      8: "Sha'ban is the month before Ramadan. Prophet Muhammad (PBUH) used to fast abundantly in this month in preparation.",
      9: "Ramadan is the holiest month where the Quran was revealed. Muslims fast from dawn to sunset and engage in intense night prayers.",
      10: "Shawwal begins with Eid al-Fitr, celebrating the end of fasting. Six days of fasting in this month are highly rewarded.",
      11: "Dhu al-Qadah is a sacred month where no warfare is permitted, bringing peace and preparation for the impending Hajj.",
      12: "Dhu al-Hijjah is the sacred month of Hajj (Pilgrimage) and Eid al-Adha. The first ten days are the best days for good deeds.",
    };

    List<String> defaultEvents = [];
    switch (month) {
      case 1:
        defaultEvents = ["10th: Day of Ashura"];
        break;
      case 3:
        defaultEvents = ["12th: Mawlid al-Nabi (Prophet's Birth)"];
        break;
      case 7:
        defaultEvents = ["27th: Isra and Mi'raj"];
        break;
      case 8:
        defaultEvents = ["15th: Mid-Sha'ban (Lailat al-Bara'at)"];
        break;
      case 9:
        defaultEvents = ["1st-30th: Fasting Month", "27th (approx): Lailat al-Qadr"];
        break;
      case 10:
        defaultEvents = ["1st: Eid al-Fitr"];
        break;
      case 12:
        defaultEvents = ["8th-13th: Hajj", "9th: Day of Arafah", "10th: Eid al-Adha"];
        break;
      default:
        defaultEvents = [];
    }

    return {"desc": info[month] ?? "", "events": defaultEvents};
  }

  void _showMonthYearPicker() {
    int selectedYear = _currentViewedMonth.hYear;
    int selectedMonth = _currentViewedMonth.hMonth;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Year & Month"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Year:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: selectedYear,
                        menuMaxHeight: 300,
                        items: List.generate(100, (i) => 1400 + i)
                            .map((y) => DropdownMenuItem(value: y, child: Text("$y AH")))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedYear = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Month:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: selectedMonth,
                        menuMaxHeight: 300,
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(value: m, child: Text(hijriMonths[m - 1])))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedMonth = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Calculate difference from base (today)
                    int monthDiff = ((selectedYear - today.hYear) * 12) + (selectedMonth - today.hMonth);
                    int targetPage = 500 + monthDiff;
                    _pageController.animateToPage(
                      targetPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Go"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddEventDialog([HijriCalendar? initialDate]) {
    final nameCtrl = TextEditingController();
    HijriCalendar selectedDate = initialDate ?? _currentViewedMonth;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Custom Event"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Event Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text("Date: ${hijriMonths[selectedDate.hMonth - 1]} ${selectedDate.hDay}, ${selectedDate.hYear}"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _userEvents.add({
                          "name": nameCtrl.text.trim(),
                          "month": selectedDate.hMonth,
                          "year": selectedDate.hYear,
                          "day": selectedDate.hDay,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event added successfully!")));
                    }
                  },
                  child: const Text("Save Event"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _gregorianBday = date;
        _hijriBday = HijriCalendar.fromDate(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthInfo = _getMonthInfo(_currentViewedMonth.hMonth);
    final defaultEvents = monthInfo["events"] as List<String>;

    // Filter user events for current month
    final activeUserEvents = _userEvents.where((e) => e["year"] == _currentViewedMonth.hYear && e["month"] == _currentViewedMonth.hMonth).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Islamic Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Select Month/Year",
            onPressed: _showMonthYearPicker,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Current Hijri date (Today)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.today, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Date", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          "${hijriMonths[today.hMonth - 1]} ${today.hDay}, ${today.hYear} AH",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// Swipe calendar
              SizedBox(
                height: 440,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentViewedMonth = _monthFromPage(index);
                    });
                  },
                  itemBuilder: (context, index) {
                    final month = _monthFromPage(index);
                    final days = HijriCalendarService.getMonthDays(month.hYear, month.hMonth);

                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${hijriMonths[month.hMonth - 1]} ${month.hYear} AH",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                              Icon(Icons.swipe, color: Colors.grey.shade300, size: 20),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 4),
                          Expanded(
                            child: CalendarGrid(
                              days: days,
                              onDayLongPressed: (selectedDay) => _showAddEventDialog(selectedDay),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// Month info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About ${hijriMonths[_currentViewedMonth.hMonth - 1]}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      monthInfo["desc"] as String,
                      style: TextStyle(height: 1.5, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Events Block
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Islamic Events",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddEventDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Event"),
                        )
                      ],
                    ),
                    const Divider(),
                    if (defaultEvents.isEmpty && activeUserEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No major historical events this month.", style: TextStyle(color: Colors.grey.shade500)),
                      ),
                    ...defaultEvents.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Text(e, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )),
                    if (activeUserEvents.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text("My Reminders", style: TextStyle(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...activeUserEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.event_note, color: Colors.blue, size: 16),
                                const SizedBox(width: 8),
                                Text("${e["day"]}th: ${e["name"]}"),
                              ],
                            ),
                          )),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Birthday calculator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cake, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      "Islamic Birthday Calculator",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Enter your Gregorian birthday to find your exact Hijri birthday.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.search),
                      label: Text(_gregorianBday == null ? "Select Birthday Date" : DateFormat('dd MMM yyyy').format(_gregorianBday!)),
                      onPressed: _pickBirthday,
                    ),
                    if (_hijriBday != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Text("Your Hijri Birthday is", style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              "${hijriMonths[_hijriBday!.hMonth - 1]} ${_hijriBday!.hDay}, ${_hijriBday!.hYear} AH",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}