// lib/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Blind AI Dating';
  static const String appNamePrivacyPolicy = 'BliindAI Dating';

  // Landing Page Taglines
  static const String landingHeadline1 = 'Tired of loneliness? Craving real connection?';
  static const String landingHeadline2 = 'Your journey to belonging begins here.';
  static const String landingTapPrompt = 'Tap the light to reveal your destiny';

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

  // General UI text
  static const String loginButtonText = 'Log In';
  static const String signupButtonText = 'Sign Up';

  // --- Theme Constants (Added for consistency) ---
  static const Color primaryColor = Color(0xFF6200EE); // Deep Purple
  static const Color accentColor = Color(0xFF03DAC6); // Teal
  static const Color backgroundColor = Colors.black; // As per your current theme
  static const Color surfaceColor = Color(0xFF121212); // Dark surface for cards, etc.
  static const Color errorColor = Color(0xFFCF6679); // Error red

  static const Color textColor = Colors.white70; // Your current text color
  static const Color textHighEmphasis = Colors.white; // For important text
  static const Color textMediumEmphasis = Colors.white70;
  static const Color textLowEmphasis = Colors.white38;

  static const MaterialColor primarySwatchColor = MaterialColor(
    0xFF6200EE, // primaryColor value
    <int, Color>{
      50: Color(0xFFEDE7F9),
      100: Color(0xFFD1C4E9),
      200: Color(0xFFB39DDB),
      300: Color(0xFF9575CD),
      400: Color(0xFF7E57C2),
      500: Color(0xFF6200EE),
      600: Color(0xFF5E35B1),
      700: Color(0xFF512DA8),
      800: Color(0xFF4527A0),
      900: Color(0xFF311B92),
    },
  );

  // Font Family is set globally in main.dart, but specific TextStyles can be defined here
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: textHighEmphasis,
    fontFamily: 'Inter',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16.0,
    color: textMediumEmphasis,
    fontFamily: 'Inter',
  );

  // Spacing and Padding
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
}