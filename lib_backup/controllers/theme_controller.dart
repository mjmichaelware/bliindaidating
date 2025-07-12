// lib/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for theme colors

/// A ChangeNotifier that manages the application's theme (light/dark mode).
///
/// It provides a [currentTheme] getter that returns a [ThemeData] object
/// based on the [_isDarkMode] state, using colors defined in [AppConstants].
/// It also offers a [toggleTheme] method to switch between light and dark modes.
class ThemeController extends ChangeNotifier {
  // Private variable to hold the current theme mode.
  // Default to dark mode as per the existing app's aesthetic.
  bool _isDarkMode = true;

  /// Returns the current theme mode.
  /// True if dark mode is active, false for light mode.
  bool get isDarkMode => _isDarkMode;

  /// Returns the [ThemeData] object corresponding to the current theme mode.
  ///
  /// This getter dynamically constructs a ThemeData object using colors
  /// from [AppConstants], ensuring consistency across the application.
  ThemeData get currentTheme {
    if (_isDarkMode) {
      // Dark Theme configuration
      return ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.dark,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.surfaceColor,
          background: AppConstants.backgroundColor,
          error: AppConstants.errorColor,
          onPrimary: AppConstants.textHighEmphasis,
          onSecondary: AppConstants.textHighEmphasis,
          onSurface: AppConstants.textHighEmphasis,
          onBackground: AppConstants.textHighEmphasis,
          onError: AppConstants.textHighEmphasis,
        ),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        cardColor: AppConstants.cardColor,
        dialogBackgroundColor: AppConstants.dialogBackgroundColor,
        textTheme: const TextTheme().apply(
          fontFamily: 'Inter', // Ensure Inter font is used for all text
          bodyColor: AppConstants.textColor,
          displayColor: AppConstants.textColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.surfaceColor,
          foregroundColor: AppConstants.textHighEmphasis,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.textHighEmphasis,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.textHighEmphasis,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLarge,
              vertical: AppConstants.spacingMedium,
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add other theme properties as needed for dark mode consistency
      );
    } else {
      // Light Theme configuration
      return ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.lightSurfaceColor,
          background: AppConstants.lightBackgroundColor,
          error: AppConstants.errorColor,
          onPrimary: AppConstants.lightTextHighEmphasis,
          onSecondary: AppConstants.lightTextHighEmphasis,
          onSurface: AppConstants.lightTextHighEmphasis,
          onBackground: AppConstants.lightTextHighEmphasis,
          onError: AppConstants.lightTextHighEmphasis,
        ),
        scaffoldBackgroundColor: AppConstants.lightBackgroundColor,
        cardColor: AppConstants.lightCardColor,
        dialogBackgroundColor: AppConstants.lightDialogBackgroundColor,
        textTheme: const TextTheme().apply(
          fontFamily: 'Inter', // Ensure Inter font is used for all text
          bodyColor: AppConstants.lightTextColor,
          displayColor: AppConstants.lightTextColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.lightSurfaceColor,
          foregroundColor: AppConstants.lightTextHighEmphasis,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.lightTextHighEmphasis,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.lightTextHighEmphasis,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLarge,
              vertical: AppConstants.spacingMedium,
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add other theme properties as needed for light mode consistency
      );
    }
  }

  /// Toggles the current theme mode between dark and light.
  /// Notifies listeners to rebuild widgets that depend on the theme.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
