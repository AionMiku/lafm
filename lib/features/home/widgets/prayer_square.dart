import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/controllers/prayer_countdown_controller.dart';
import '../../../core/providers/prayer_settings_provider.dart';

class PrayerSquare extends StatefulWidget {
  const PrayerSquare({super.key});

  @override
  State<PrayerSquare> createState() => _PrayerSquareState();
}

class _PrayerSquareState extends State<PrayerSquare> {
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
    final activeColor = PrayerSettingsProvider.getPrayerIconColor(nextPrayer);
    final themePrimary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 220, // Rectangular aspect constraint
      child: Stack(
        children: [
          // 1. The Mathematical Progress Paint
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomPaint(
                painter: _SquareProgressPainter(
                  progress: progress,
                  activeColor: themePrimary,
                  bgColor: themePrimary.withOpacity(0.15),
                  strokeWidth: 8.0,
                  radius: 16.0,
                ),
              ),
            ),
          ),

          // 2. Center Timer Information
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextPrayer.isEmpty ? 'Loading' : '${nextPrayer.toUpperCase()} IN',
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _format(remaining),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // 3. Perimeter Tracking Icons (Replacing textual names, intersecting the path line)
          const _PrayerIconNode(prayerName: 'Fajr', alignment: Alignment.topCenter),
          const _PrayerIconNode(prayerName: 'Dhuhr', alignment: Alignment.centerRight),
          const _PrayerIconNode(prayerName: 'Asr', alignment: Alignment.bottomRight),
          const _PrayerIconNode(prayerName: 'Maghrib', alignment: Alignment.bottomLeft),
          const _PrayerIconNode(prayerName: 'Isha', alignment: Alignment.centerLeft),
        ],
      ),
    );
  }
}

class _PrayerIconNode extends StatelessWidget {
  final String prayerName;
  final Alignment alignment;
  
  const _PrayerIconNode({required this.prayerName, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final icon = PrayerSettingsProvider.getPrayerIcon(prayerName);
    final color = PrayerSettingsProvider.getPrayerIconColor(prayerName);

    // A 24px icon with 0 padding placed against a parent aligns its center exactly at distance 12px from the edge.
    // Since our graphic path is padded by 12.0px, 0 padding creates perfect geometric intersection for straight lines!
    // For corners, we push them in slightly to rest on the 16px border radii curves.
    EdgeInsets getPadding() {
      if (alignment == Alignment.bottomRight) return const EdgeInsets.only(bottom: 6, right: 6);
      if (alignment == Alignment.bottomLeft) return const EdgeInsets.only(bottom: 6, left: 6);
      return EdgeInsets.zero;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: getPadding(),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SquareProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color bgColor;
  final double strokeWidth;
  final double radius;

  _SquareProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.bgColor,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = radius;

    // We manually construct our Path explicitly starting from the exact Top-Center! (For Fajr)
    final Path path = Path();
    path.moveTo(w / 2, 0); // Start top-center
    path.lineTo(w - r, 0); // Go right
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r)); // Corner bounds
    path.lineTo(w, h - r); // Go down
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    path.lineTo(r, h); // Go left
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    path.lineTo(0, r); // Go up
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(w / 2, 0); // Back to top-center closure!

    // Establish a layer so BlendMode.clear punches only through the stroke, not the OS background!
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());

    // 1. Paint underlying rail
    final Paint bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    // 2. Dynamically extract the portion of the path for the real percentage
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final double extractLength = metric.length * progress;
      final Path progressPath = metric.extractPath(0, extractLength);

      final Paint activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(progressPath, activePaint);
    }

    // 3. Clear overlapping holes precisely where the icons sit to prevent line overlap
    final Paint eraser = Paint()..blendMode = BlendMode.clear;
    const double holeRadius = 14.0;
    final double rCorner = r - (r * 0.7071); // 45-degree corner offset math
    
    canvas.drawCircle(Offset(w / 2, 0), holeRadius, eraser); // Top Center
    canvas.drawCircle(Offset(w, h / 2), holeRadius, eraser); // Center Right
    canvas.drawCircle(Offset(w - rCorner, h - rCorner), holeRadius, eraser); // Bottom Right
    canvas.drawCircle(Offset(rCorner, h - rCorner), holeRadius, eraser); // Bottom Left
    canvas.drawCircle(Offset(0, h / 2), holeRadius, eraser); // Center Left

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SquareProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.activeColor != activeColor;
  }
}
