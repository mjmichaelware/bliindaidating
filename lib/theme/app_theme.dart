// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // Ensure this import is correct

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppConstants.lightPrimaryColor,
    colorScheme: ColorScheme.light(
      primary: AppConstants.lightPrimaryColor,
      secondary: AppConstants.lightSecondaryColor,
      surface: AppConstants.lightSurfaceColor,
      background: AppConstants.lightBackgroundColor,
      error: AppConstants.errorColor,
      onPrimary: Colors.black, // Text on primary color
      onSecondary: Colors.black, // Text on secondary color
      onSurface: AppConstants.lightTextColor,
      onBackground: AppConstants.lightTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppConstants.lightBackgroundColor,
    appBarTheme: AppBarTheme(
      color: AppConstants.lightBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppConstants.lightIconColor),
      titleTextStyle: TextStyle(
        color: AppConstants.lightTextHighEmphasis,
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    ),
    cardColor: AppConstants.lightCardColor,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: AppConstants.fontSizeTitle,
        fontWeight: FontWeight.w900,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: AppConstants.fontSizeHeadline,
        fontWeight: FontWeight.w800,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        fontSize: AppConstants.fontSizeExtraLarge,
        fontWeight: FontWeight.w700,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        color: AppConstants.lightTextMediumEmphasis,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeSmall,
        color: AppConstants.lightTextMediumEmphasis,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: AppConstants.lightTextHighEmphasis,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeSmall - 2,
        color: AppConstants.lightTextLowEmphasis,
        fontFamily: 'Inter',
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppConstants.lightPrimaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.lightPrimaryColor,
        foregroundColor: Colors.white, // Text color for ElevatedButton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
        textStyle: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.lightSecondaryColor, // Text color for TextButton
        textStyle: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontFamily: 'Inter',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.lightSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.lightBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.lightPrimaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: AppConstants.lightTextMediumEmphasis),
      hintStyle: TextStyle(color: AppConstants.lightTextLowEmphasis),
    ),
    iconTheme: const IconThemeData(color: AppConstants.lightIconColor),
    dividerColor: AppConstants.lightBorderColor,
  );

  // --- Dark Theme (Galaxy Theme) ---
  static final ThemeData galaxyTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppConstants.primaryColor,
    colorScheme: ColorScheme.dark(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      surface: AppConstants.surfaceColor,
      background: AppConstants.backgroundColor,
      error: AppConstants.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppConstants.textColor,
      onBackground: AppConstants.textColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    appBarTheme: AppBarTheme(
      color: AppConstants.backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppConstants.iconColor),
      titleTextStyle: TextStyle(
        color: AppConstants.textHighEmphasis,
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    ),
    cardColor: AppConstants.cardColor,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: AppConstants.fontSizeTitle,
        fontWeight: FontWeight.w900,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: AppConstants.fontSizeHeadline,
        fontWeight: FontWeight.w800,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        fontSize: AppConstants.fontSizeExtraLarge,
        fontWeight: FontWeight.w700,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        color: AppConstants.textMediumEmphasis,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeSmall,
        color: AppConstants.textMediumEmphasis,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: AppConstants.textHighEmphasis,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeSmall - 2,
        color: AppConstants.textLowEmphasis,
        fontFamily: 'Inter',
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppConstants.primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white, // Text color for ElevatedButton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
        textStyle: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.secondaryColor, // Text color for TextButton
        textStyle: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontFamily: 'Inter',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: AppConstants.textMediumEmphasis),
      hintStyle: TextStyle(color: AppConstants.textLowEmphasis),
    ),
    iconTheme: const IconThemeData(color: AppConstants.iconColor),
    dividerColor: AppConstants.borderColor.withOpacity(0.5),
  );
}