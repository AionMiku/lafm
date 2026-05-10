import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'navigation/bottom_nav.dart';
import 'core/settings/global_settings_controller.dart';
import 'core/settings/theme_controller.dart';
import 'core/settings/app_theme.dart';
import 'core/providers/prayer_settings_provider.dart';

import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LafmApp());
}

class LafmApp extends StatelessWidget {
  const LafmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalSettingsController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => PrayerSettingsProvider()),
      ],
      child: Consumer2<GlobalSettingsController, ThemeController>(
        builder: (context, settings, themeCtrl, _) {

          /// Wait until settings are loaded
          if (!settings.isReady || !themeCtrl.isReady) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'LAFM',

            /// App Theme
            themeMode: ThemeMode.light, // Locked to Glass Theme!
            theme: AppTheme.getLightTheme(themeCtrl.primaryColor, themeCtrl.glassOpacity),

            builder: (context, child) {
              // Create a dynamic deep gradient based on the selected seed color
              // Convert primaryColor to HSL to darken it safely for the background
              final hsl = HSLColor.fromColor(themeCtrl.primaryColor);
              final Color topGradient = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
              final Color midGradient = hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      topGradient.withOpacity(0.7), // Brighter tinted top
                      midGradient.withOpacity(0.4), // Brighter middle
                      const Color(0xFF021210), // Slightly lighter dark base
                    ],
                    stops: const [0.1, 0.5, 0.9],
                  ),
                ),
                child: Stack(
                  children: [
                    // Dynamic radial glow orb based on primaryColor
                    Positioned(
                      bottom: -100,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              themeCtrl.primaryColor.withOpacity(0.15),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ),
                    // The actual screen content
                    if (child != null) child,
                  ],
                ),
              );
            },
            home: settings.isFirstLaunch ? const OnboardingScreen() : const MainNavigation(),
          );
        },
      ),
    );
  }
}