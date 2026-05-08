import 'package:flutter/material.dart';

class AppTheme {
  // Custom Light Mode ("Nordic Ummah Glassmorphism Theme")
  static const Color scaffoldLight = Colors.transparent; 
  static const Color surfaceLight = Colors.transparent; 

  static ThemeData getLightTheme(Color userSeedColor, double glassOpacity) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, 
      scaffoldBackgroundColor: scaffoldLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: userSeedColor,
        primary: userSeedColor,
        brightness: Brightness.dark, 
        surface: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white.withOpacity(glassOpacity + 0.01), 
        foregroundColor: Colors.white, 
      ),
      textTheme: Typography.material2021().white.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white60), 
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      cardColor: Colors.white.withOpacity(glassOpacity), 
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(glassOpacity),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.0), 
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(glassOpacity + 0.01), 
        selectedItemColor: userSeedColor,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
