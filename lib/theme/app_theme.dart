// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for shared colors

class AppTheme {
  static const Color primaryColor = Color(0xFF8A2BE2); // Amethyst purple
  static const Color accentColor = Color(0xFF00FFFF); // Cyan
  static const Color cardColor = Color(0xFF1C1C3A); // Slightly lighter dark blue
  static const Color successColor = Color(0xFF32CD32); // Lime green
  static const Color dangerColor = Color(0xFFFF4500); // Orange red

  static ThemeData get galaxyTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      hintColor: accentColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor, // Use AppConstants for background
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.textColor),
        titleTextStyle: TextStyle(color: AppConstants.textColor, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      cardColor: cardColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textColor, fontSize: 36, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: accentColor)]),
        displayMedium: TextStyle(color: AppConstants.textColor, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppConstants.textColor, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppConstants.textColor, fontSize: 18, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppConstants.textColor, fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppConstants.textColor, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppConstants.textColor, fontSize: 16),
        bodyMedium: TextStyle(color: AppConstants.textColor, fontSize: 14),
        labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: primaryColor,
        selectionHandleColor: accentColor,
      ),
    );
  }

  // Example of a light theme if you were to implement dark/light switching
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      hintColor: accentColor,
      scaffoldBackgroundColor: AppConstants.lightBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.lightTextColor),
        titleTextStyle: TextStyle(color: AppConstants.lightTextColor, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      cardColor: Colors.white,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.lightTextColor, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: AppConstants.lightTextColor, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: AppConstants.lightTextColor, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppConstants.lightTextColor, fontSize: 18, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppConstants.lightTextColor, fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: AppConstants.lightTextColor, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppConstants.lightTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: AppConstants.lightTextColor, fontSize: 14),
        labelLarge: TextStyle(color: AppConstants.lightTextColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor,
        selectionHandleColor: primaryColor,
      ),
    );
  }
}