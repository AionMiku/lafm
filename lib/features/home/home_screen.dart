import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings/global_settings_controller.dart';
import 'widgets/header.dart';
import 'widgets/menu_icons.dart';
import 'widgets/islamic_date.dart';
import 'widgets/prayer_ring.dart';
import 'widgets/prayer_square.dart';
import 'widgets/prayer_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _cardWrapper(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

          /// HEADER
          const HomeHeader(),

          const SizedBox(height: 6),

          /// QUICK TOOLS
          const MenuIconsRow(),

          /// ISLAMIC DATE CARD
          _cardWrapper(context, const IslamicDate()),

          /// PRAYER RING/SQUARE CARD MULTIPLEXER
          Consumer<GlobalSettingsController>(
            builder: (context, globalSettings, _) {
              return _cardWrapper(
                context,
                SizedBox(
                  height: 260,
                  child: Center(
                    child: globalSettings.prayerTimerStyle == 'square'
                        ? const PrayerSquare()
                        : const PrayerRing(),
                  ),
                ),
              );
            },
          ),

          /// PRAYER TIMES
          const PrayerList(),

          const SizedBox(height: 10),

          /// ADVERTISEMENT CARD
          _cardWrapper(
            context,
            Container(
              width: double.infinity,
              height: 100, // Fixed height for ad banner
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.campaign, size: 40, color: Colors.white54),
                  ),
                  Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Sponsored Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

          const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }
}