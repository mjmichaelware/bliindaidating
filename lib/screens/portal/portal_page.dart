// lib/screens/portal/portal_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG assets
import 'package:provider/provider.dart'; // Import for ThemeController

// Import the painters and other widgets defined within landing_page.dart
// Ensure these imports are correct and the widgets exist in landing_page.dart
import 'package:bliindaidating/landing_page/landing_page.dart'; // Contains NebulaBackgroundPainter, ParticleFieldPainter, AnimatedGlowText, InsightCrystal, FooterNavLink
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for theme values and SVG paths
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController

// Import info screens as they are navigated to from this page
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';

class PortalPage extends StatefulWidget {
  const PortalPage({super.key});

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> with TickerProviderStateMixin {
  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _orbGlowController;
  late Animation<double> _orbGlowAnimation;
  late AnimationController _textSparkleController;
  late Animation<double> _textSparkleAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  final List<Map<String, dynamic>> _aiInsights = [
    {
      'title': 'DEEPER COMPATIBILITY',
      'description': 'Our AI analyzes personality, values, and communication styles, going beyond surface-level traits to find your true match.',
      'svgAssetPath': AppConstants.svgLoveAndDating3, // Using SVG asset
      'color': AppConstants.complementaryColor1, // Using AppConstants
    },
    {
      'title': 'REDUCED SHALLOWNESS',
      'description': 'No endless swiping. Our algorithm presents carefully curated profiles, encouraging genuine interest based on substance.',
      'svgAssetPath': AppConstants.svgLoveAndDating10, // Using SVG asset
      'color': AppConstants.complementaryColor3, // Using AppConstants
    },
    {
      'title': 'GUIDED CONVERSATIONS',
      'description': 'AI-powered prompts encourage meaningful dialogue, helping you connect on a deeper level before meeting in person.',
      'svgAssetPath': AppConstants.svgLoveAndDating6, // Using SVG asset
      'color': AppConstants.secondaryColor, // Using AppConstants
    },
    {
      'title': 'PERSONALIZED JOURNEY',
      'description': 'The AI learns from your interactions and feedback, continuously refining its recommendations to better understand your unique preferences.',
      'svgAssetPath': AppConstants.svgLoveAndDating12, // Using SVG asset
      'color': AppConstants.primaryColor, // Using AppConstants
    },
    {
      'title': 'TIME EFFICIENCY',
      'description': 'Spend less time sifting through incompatible profiles. Our AI streamlines the discovery process to bring you quality connections.',
      'svgAssetPath': AppConstants.svgLoveAndDating5, // Using SVG asset
      'color': AppConstants.complementaryColor2, // Using AppConstants
    },
  ];

  @override
  void initState() {
    super.initState();
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _orbGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 5), reverseDuration: const Duration(seconds: 4))..repeat(reverse: true);
    _orbGlowAnimation = CurvedAnimation(parent: _orbGlowController, curve: Curves.easeInOutSine);

    _textSparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6), reverseDuration: const Duration(seconds: 5))..repeat(reverse: true);
    _textSparkleAnimation = CurvedAnimation(parent: _textSparkleController, curve: Curves.easeInOutCirc);

    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;
    final bool isMediumScreen = size.width >= 600 && size.width < 1000;

    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundNebulaController,
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaBackgroundPainter(
                    _backgroundNebulaAnimation,
                    isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade900,
                    isDarkMode ? AppConstants.secondaryColorShade900 : AppConstants.lightSecondaryColorShade900,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _nebulaParticles,
                _textSparkleAnimation,
                isSmallScreen ? 1.0 : 2.0,
                isDarkMode ? AppConstants.secondaryColor.withOpacity(0.8) : AppConstants.secondaryColor.withOpacity(0.5),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _orbGlowAnimation,
                isSmallScreen ? 0.7 : 1.5,
                isDarkMode ? AppConstants.primaryColor.withOpacity(0.8) : AppConstants.primaryColor.withOpacity(0.5),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? AppConstants.spacingMedium : (isMediumScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),
              vertical: isSmallScreen ? AppConstants.spacingLarge : (isMediumScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedGlowText(
                  text: AppConstants.portalIntroTitle, // Using AppConstants
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isSmallScreen ? AppConstants.fontSizeTitle : (isMediumScreen ? 50 : 60),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    letterSpacing: 1.5,
                  ),
                  glowColorTween: ColorTween(
                    begin: isDarkMode ? AppConstants.secondaryColorShade700 : AppConstants.lightSecondaryColorShade700,
                    end: isDarkMode ? AppConstants.complementaryColor2.shade700 : AppConstants.lightPrimaryColor.shade700, // Using a complementary color
                  ),
                  blurRadius: isSmallScreen ? 20 : 40,
                  animationDuration: const Duration(seconds: 5),
                  animationCurve: Curves.easeInOutQuad,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingExtraLarge : AppConstants.spacingXXXL),
                Text(
                  AppConstants.portalIntroDescription, // Using AppConstants
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isSmallScreen ? AppConstants.fontSizeBody : AppConstants.fontSizeLarge,
                    color: (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),

                // AI Insights Section
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXXL,
                    runSpacing: isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXXL,
                    children: _aiInsights.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return InsightCrystal(
                        title: data['title'] as String,
                        description: data['description'] as String,
                        svgAssetPath: data['svgAssetPath'] as String, // Corrected to svgAssetPath
                        baseColor: data['color'] as Color,
                        isSmallScreen: isSmallScreen,
                        staggerDelay: index.toDouble(),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),

                // Login/Signup Buttons
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    border: Border.all(color: (isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor).withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.05),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ready to Manifest Your Destiny?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isSmallScreen ? AppConstants.fontSizeExtraLarge : AppConstants.fontSizeTitle,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
                      SizedBox(
                        width: isSmallScreen ? double.infinity : 300,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor, // Use AppConstants
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)), // Use AppConstants
                          ),
                          child: Text(
                            AppConstants.loginButtonText, // Use AppConstants
                            style: TextStyle(
                              fontSize: isSmallScreen ? AppConstants.fontSizeMedium : AppConstants.fontSizeLarge,
                              color: AppConstants.textHighEmphasis, // Use AppConstants
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium),
                      SizedBox(
                        width: isSmallScreen ? double.infinity : 300,
                        child: OutlinedButton(
                          onPressed: () => context.go('/signup'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppConstants.secondaryColor, width: 2), // Use AppConstants
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium)), // Use AppConstants
                          ),
                          child: Text(
                            AppConstants.signupButtonText, // Use AppConstants
                            style: TextStyle(
                              fontSize: isSmallScreen ? AppConstants.fontSizeMedium : AppConstants.fontSizeLarge,
                              color: AppConstants.secondaryColor, // Use AppConstants
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),

                // Footer Links
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeTransition(
                    opacity: _textSparkleAnimation, // Reuse existing animation
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge,
                          runSpacing: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium,
                          children: [
                            FooterNavLink(
                              label: 'About Us',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
                              isSmallScreen: isSmallScreen,
                              animation: _textSparkleAnimation,
                            ),
                            FooterNavLink(
                              label: 'Privacy Policy',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen())),
                              isSmallScreen: isSmallScreen,
                              animation: _textSparkleAnimation,
                            ),
                            FooterNavLink(
                              label: 'Terms of Service',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsScreen())),
                              isSmallScreen: isSmallScreen,
                              animation: _textSparkleAnimation,
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium),
                        Text(
                          '© 2025 Blind AI Dating.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium,
                            color: (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
