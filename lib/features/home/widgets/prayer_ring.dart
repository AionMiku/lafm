import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/controllers/prayer_countdown_controller.dart';
import '../../../core/providers/prayer_settings_provider.dart';

class PrayerRing extends StatefulWidget {
  const PrayerRing({super.key});

  @override
  State<PrayerRing> createState() => _PrayerRingState();
}

class _PrayerRingState extends State<PrayerRing> {
  final controller = PrayerCountdownController();

  String nextPrayer = '';
  Duration remaining = Duration.zero;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    controller.start((data) {
      if (!mounted) return;
      setState(() {
        nextPrayer = data.nextPrayer;
        remaining = data.remaining;
        progress = data.dayProgress;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = PrayerSettingsProvider.getPrayerIconColor(nextPrayer);
    final icon = PrayerSettingsProvider.getPrayerIcon(nextPrayer);
    final themePrimary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: CircularPercentIndicator(
          radius: 125,
          lineWidth: 12,
          percent: progress,
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 1000,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: themePrimary,
          backgroundColor: themePrimary.withOpacity(0.25),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: ringColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    nextPrayer.isEmpty ? 'Next Prayer' : '$nextPrayer in :',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _format(remaining),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
