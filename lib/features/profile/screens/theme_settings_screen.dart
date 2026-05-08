import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/settings/theme_controller.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Glass Opacity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adjust the transparency of the frosted glass cards.',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              
              // Glass Opacity Slider
              Row(
                children: [
                  const Icon(Icons.blur_on, color: Colors.white54),
                  Expanded(
                    child: Slider(
                      value: themeCtrl.glassOpacity,
                      min: 0.0,
                      max: 0.20, // 0 to 20%
                      divisions: 20,
                      activeColor: themeCtrl.primaryColor,
                      inactiveColor: Colors.white24,
                      label: '${(themeCtrl.glassOpacity * 100).toInt()}%',
                      onChanged: (val) {
                        themeCtrl.setGlassOpacity(val);
                      },
                    ),
                  ),
                  const Icon(Icons.blur_off, color: Colors.white54),
                ],
              ),
              
              const SizedBox(height: 40),

              const Text(
                'Theme Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap or drag to select your app\'s accent and background color.',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Square Color Picker
              _SquareColorPicker(
                currentColor: themeCtrl.primaryColor,
                onColorChanged: (newColor) {
                  themeCtrl.setPrimaryColor(newColor);
                },
              ),
              
              const SizedBox(height: 40),
              
              // Preview Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(themeCtrl.glassOpacity),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
                ),
                child: Column(
                  children: [
                    Icon(Icons.color_lens, size: 48, color: themeCtrl.primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Theme Preview',
                      style: TextStyle(
                        color: themeCtrl.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This is how your glass cards will look with the selected opacity and color settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SquareColorPicker extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const _SquareColorPicker({
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<_SquareColorPicker> createState() => _SquareColorPickerState();
}

class _SquareColorPickerState extends State<_SquareColorPicker> {
  void _handleDrag(BuildContext context, Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final double width = box.size.width;
    final double height = box.size.height;
    
    final double dx = localPosition.dx.clamp(0.0, width);
    final double dy = localPosition.dy.clamp(0.0, height);
    
    // Map X to Hue (0 to 360)
    final double hue = (dx / width) * 360.0;
    
    // Map Y to Saturation (1.0 at top, 0.0 at bottom)
    final double saturation = 1.0 - (dy / height);
    
    // Use Value = 1.0 (max brightness)
    final Color newColor = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
    widget.onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    // Current hue and saturation for the thumb position
    final HSVColor currentHsv = HSVColor.fromColor(widget.currentColor);
    final double currentHue = currentHsv.hue;
    final double currentSaturation = currentHsv.saturation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = 220.0; // Square-ish height

        final double thumbX = (currentHue / 360.0) * width;
        final double thumbY = (1.0 - currentSaturation) * height;

        return GestureDetector(
          onPanUpdate: (details) => _handleDrag(context, details.localPosition),
          onTapDown: (details) => _handleDrag(context, details.localPosition),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Rainbow Hue layer (Horizontal Gradient)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0000), // 0
                        Color(0xFFFFFF00), // 60
                        Color(0xFF00FF00), // 120
                        Color(0xFF00FFFF), // 180
                        Color(0xFF0000FF), // 240
                        Color(0xFFFF00FF), // 300
                        Color(0xFFFF0000), // 360
                      ],
                      stops: [0.0, 0.166, 0.333, 0.5, 0.666, 0.833, 1.0],
                    ),
                  ),
                ),
                
                // 2. White to Transparent layer (Vertical Gradient) for Saturation
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.white, Colors.transparent],
                    ),
                  ),
                ),

                // The Thumb indicator
                Positioned(
                  left: (thumbX - 15).clamp(0.0, width - 30),
                  top: (thumbY - 15).clamp(0.0, height - 30),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
