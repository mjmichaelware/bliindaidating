// lib/app_constants.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform; // IMPORTANT: Add this import for Platform detection

class AppConstants {
  static const String appName = 'Blind AI Dating';
  static const String appNamePrivacyPolicy = 'BliindAI Dating';

  // --- API Base URL ---
  static String get baseUrl {
    // For Android emulator, use 10.0.2.2 to access your host machine's localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    // For iOS simulator, localhost/127.0.0.1 typically works
    else if (Platform.isIOS) {
      return 'http://127.0.0.1:8000';
    }
    // For Flutter Web, 'localhost' often works directly, or 127.0.0.1
    // For desktop platforms (Linux, Windows, macOS), 127.0.0.1 also works
    else {
      return 'http://127.0.0.1:8000';
    }
    // Remember: For physical Android devices, you'd need your host machine's actual IP address
    // (e.g., 'http://192.168.1.100:8000') and ensure devices are on same Wi-Fi.
  }
  // --- END API Base URL ---

  // Admin Email - ADDED THIS LINE TO FIX COMPILATION ERROR
  static const String adminEmail = 'your_admin_email@example.com';


  // Landing Page Taglines
  static const String landingHeadline1 = 'Tired of loneliness? Craving real connection?';
  static const String landingHeadline2 = 'Your journey to belonging begins here.';
  static const String landingTapPrompt = 'Tap the light to reveal your destiny';
  static const String landingTagline = 'Find your connection in the stars'; // New tagline

  // Access Portal Screen Content
  static const String portalIntroTitle = 'Your Journey to Authentic Connection';
  static const String portalIntroDescription = 'Discover deep connections, powered by revolutionary AI matchmaking. Our unique algorithms prioritize genuine compatibility based on your honest inputs, crafting personalized date experiences tailored to your availability and location. Find your true soulmate, effortlessly.';

  static const String aiPowerTitle = 'The Precision of AI Matchmaking';
  static const String aiPowerBody = 'Our advanced AI analyzes your core personality, values, and communication style, not just superficial traits. The more open and truthful you are in your profile and questionnaires, the more accurately our algorithms can match you with someone truly compatible. This commitment to honesty ensures more successful and meaningful connections.';

  static const String dateAutomationTitle = 'Your Perfect Date, Effortlessly Arranged';
  static const String dateAutomationBody = 'Once our AI finds your ideal match, Blind AI Dating removes the stress of planning. We automatically propose a date, time, and a thoughtfully chosen public venue based on both your availabilities and locations. All you need to do is show up and connect with confidence, knowing every detail is handled for you.';

  static const String privacyPromiseTitle = 'Privacy & Security: Our Unwavering Commitment';
  static const String privacyPromiseBody = 'Your trust is our foundation. We employ robust security measures and strict privacy protocols to protect your personal information. Our blind matching feature ensures first impressions are built on genuine conversation, providing a safe and respectful environment for every interaction.';

  // Paths to your SVG assets (match these to your filenames exactly)
  static const String svgAiCompatibility = 'assets/svg/DrawKit Vector Illustration Love & Dating (3).svg';
  static const String svgHonesty = 'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg';
  static const String svgDatePlanning = 'assets/svg/DrawKit Vector Illustration Love & Dating (6).svg';
  static const String svgPrivacyShield = 'assets/svg/DrawKit Vector Illustration Love & Dating (5).svg';
  // All listed SVG assets for InsightCrystal
  static const String svgLoveAndDating1 = 'assets/svg/DrawKit Vector Illustration Love & Dating (1).svg';
  static const String svgLoveAndDating2 = 'assets/svg/DrawKit Vector Illustration Love & Dating (2).svg';
  static const String svgLoveAndDating3 = 'assets/svg/DrawKit Vector Illustration Love & Dating (3).svg';
  static const String svgLoveAndDating4 = 'assets/svg/DrawKit Vector Illustration Love & Dating (4).svg';
  static const String svgLoveAndDating5 = 'assets/svg/DrawKit Vector Illustration Love & Dating (5).svg';
  static const String svgLoveAndDating6 = 'assets/svg/DrawKit Vector Illustration Love & Dating (6).svg';
  static const String svgLoveAndDating7 = 'assets/svg/DrawKit Vector Illustration Love & Dating (7).svg';
  static const String svgLoveAndDating8 = 'assets/svg/DrawKit Vector Illustration Love & Dating (8).svg';
  static const String svgLoveAndDating9 = 'assets/svg/DrawKit Vector Illustration Love & Dating (9).svg';
  static const String svgLoveAndDating10 = 'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg';
  static const String svgLoveAndDating11 = 'assets/svg/DrawKit Vector Illustration Love & Dating (11).svg';
  static const String svgLoveAndDating12 = 'assets/svg/DrawKit Vector Illustration Love & Dating (12).svg';


  // General UI text
  static const String loginButtonText = 'Log In';
  static const String signupButtonText = 'Sign Up';

  // --- Theme Constants ---
  // Primary and Secondary colors (keeping your original definitions from your main.dart theme)
  static const Color primaryColor = Color(0xFFE91E63); // Pink/Red from main.dart
  static const Color secondaryColor = Color(0xFF2196F3); // Blue/Cyan from main.dart

  // Explicit shades for primary and secondary colors (dark theme)
  static const Color primaryColorShade900 = Color(0xFF880E4F); // Deepest shade of primary
  static const Color primaryColorShade700 = Color(0xFFC2185B); // Darker shade of primary
  static const Color primaryColorShade400 = Color(0xFFEC407A); // Lighter shade of primary

  static const Color secondaryColorShade900 = Color(0xFF0D47A1); // Deepest shade of secondary
  static const Color secondaryColorShade700 = Color(0xFF1976D2); // Darker shade of secondary
  static const Color secondaryColorShade400 = Color(0xFF42A5F5); // Lighter shade of secondary

  // Accent colors for AppBar, mapping to secondary colors
  static const Color accentColor = secondaryColor;
  static const Color lightAccentColor = lightSecondaryColor;


  // New colors to expand the palette based on the cosmic theme suggestion
  static const Color tertiaryColor = Color(0xFF8E24AA); // A deep purple
  static const Color complementaryColor1 = Color(0xFF00BCD4); // Cyan for contrast
  static const Color complementaryColor2 = Color(0xFF4CAF50); // Green for balance
  static const Color complementaryColor3 = Color(0xFFFFC107); // Amber for warmth
  static const Color complementaryColor4 = Color(0xFF9C27B0); // Another shade of purple

  // Explicit shade for complementaryColor2
  static const Color complementaryColor2Shade700 = Color(0xFF2E7D32); // Darker shade of complementaryColor2

  // NEW: Success Color (used for online indicator, cosmic credits)
  static const Color successColor = AppConstants.complementaryColor2; // Reusing an existing green for consistency

  // Background and surface colors for dark theme
  static const Color backgroundColor = Colors.black; // As per your current theme
  static const Color surfaceColor = Color(0xFF1A1A1A); // Darker surface for cards/containers
  static const Color cardColor = Color(0xFF2C2C2C); // Slightly lighter than surface for cards
  static const Color dialogBackgroundColor = Color(0xFF2A2A2A); // Background for modals/dialogs

  // Text colors for dark theme
  static const Color textColor = Colors.white; // Changed from white70 for better visibility as per original landing page
  static const Color textHighEmphasis = Colors.white; // For important text
  static const Color textMediumEmphasis = Colors.white70;
  static const Color textLowEmphasis = Colors.white54;
  static const Color iconColor = Colors.white; // A general color for icons
  static const Color borderColor = Colors.white; // For borders on elements
  static const Color errorColor = Color(0xFFCF6679); // Error red

  // Light Theme Colors (for theme toggle)
  static const Color lightBackgroundColor = Color(0xFFF0F2F5);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFF8F8F8);
  static const Color lightDialogBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightTextColor = Colors.black87;
  static const Color lightTextHighEmphasis = Colors.black;
  static const Color lightTextMediumEmphasis = Colors.black54;
  static const Color lightTextLowEmphasis = Colors.black38;
  static const Color lightIconColor = Colors.black87;
  static const Color lightBorderColor = Colors.black12;

  // Explicit shades for primary and secondary colors (light theme)
  static const Color lightPrimaryColor = Color(0xFFFFCDD2); // Lighter pink for light theme
  static const Color lightPrimaryColorShade900 = Color(0xFFB71C1C); // Darker red for light theme
  static const Color lightPrimaryColorShade700 = Color(0xFFD32F2F);
  static const Color lightPrimaryColorShade400 = Color(0xFFEF5350);

  static const Color lightSecondaryColor = Color(0xFFBBDEFB); // Lighter blue for light theme
  static const Color lightSecondaryColorShade900 = Color(0xFF0D47A1); // Darker blue for light theme
  static const Color lightSecondaryColorShade700 = Color(0xFF1976D2);
  static const Color lightSecondaryColorShade400 = Color(0xFF42A5F5);

  // NEW: Colors for the Phase 2 Completion Banner
  static const Color bannerBackgroundColorDark = Color(0xFF4A148C); // Deep Purple
  static const Color bannerBackgroundColorLight = Color(0xFFD1C4E9); // Lighter purple for light theme

  static const Color bannerTextColorDark = Colors.white;
  static const Color bannerTextColorLight = Colors.black87;

  static const Color bannerButtonColorDark = Color(0xFF0D47A1); // Galaxy Blue (Darker Secondary)
  static const Color bannerButtonColorLight = Color(0xFFBBDEFB); // Lighter blue

  static const Color bannerButtonTextColorDark = Colors.white;
  static const Color bannerButtonTextColorLight = Colors.black87;


  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;
  static const double spacingXXXXL = 96.0;


  // Padding
  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 25.0;
  static const double borderRadiusCircular = 1000.0;
  static const double borderRadius = 16.0;


  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeTitle = 36.0;
  static const double fontSizeHeadline = 28.0;
  static const double fontSizeBody = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0; // This is the one that was missing/causing issues
  static const double iconSizeExtraLarge = 48.0; // Re-adding this as it was in my previous comprehensive list


  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(seconds: 1);
  static const Duration animationDurationExtraLong = Duration(seconds: 2);

  // Avatar Radius
  static const double avatarRadius = 40.0;

  // Date Formatter (NEWLY ADDED)
  static final DateFormat dateFormatter = DateFormat('yyyy-MM-dd'); // Formats date as YYYY-MM-DD

  // NEW: Dashboard Side Menu Width
  static const double dashboardSideMenuWidth = 280.0;
}