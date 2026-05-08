import 'dart:ui';
import 'package:flutter/material.dart';
import '../../calendar/screens/islamic_calendar_screen.dart';
import '../../map/screens/qibla_map_screen.dart';
import '../screens/prayer_notifications_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/settings/global_settings_controller.dart';

class MenuIconsRow extends StatelessWidget {
  const MenuIconsRow({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _icon(context, Icons.calendar_month, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IslamicCalendarScreen(),
                  ),
                );
              }),
              _icon(context, Icons.mosque, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QiblaMapScreen(),
                  ),
                );
              }),
              _icon(context, Icons.favorite_border, () {}),
              _icon(context, Icons.access_time, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrayerNotificationsScreen(),
                  ),
                );
              }),
              Consumer<GlobalSettingsController>(
                builder: (context, globalSettings, child) {
                  final isArabic = globalSettings.isArabicOnlyMode;
                  return _icon(
                    context, 
                    isArabic ? Icons.language : Icons.g_translate, 
                    () {
                      globalSettings.toggleArabicOnlyMode();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'English restored.' : 'تم تفعيل الوضع العربي (Arabic Mode Active)'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context, IconData icon, VoidCallback onTap) {

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}