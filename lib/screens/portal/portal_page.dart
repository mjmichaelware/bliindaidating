import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math; // <-- FIX APPLIED HERE
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bliindaidating/landing_page/landing_page.dart'; // Import the painters and other widgets defined within it

// Import info screens as they are navigated to from this page
import 'package:bliindaidating/screens/info/about_us_screen.dart'; // <-- FIX APPLIED HERE
import 'package:bliindaidating/screens/info/privacy_screen.dart';   // <-- FIX APPLIED HERE
import 'package:bliindaidating/screens/info/terms_screen.dart';     // <-- FIX APPLIED HERE


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
      'icon': FontAwesomeIcons.robot,
      'color': Colors.tealAccent.shade400,
    },
    {
      'title': 'REDUCED SHALLOWNESS',
      'description': 'No endless swiping. Our algorithm presents carefully curated profiles, encouraging genuine interest based on substance.',
      'icon': FontAwesomeIcons.filter,
      'color': Colors.amberAccent.shade400,
    },
    {
      'title': 'GUIDED CONVERSATIONS',
      'description': 'AI-powered prompts encourage meaningful dialogue, helping you connect on a deeper level before meeting in person.',
      'icon': FontAwesomeIcons.comments,
      'color': Colors.lightBlueAccent.shade400,
    },
    {
      'title': 'PERSONALIZED JOURNEY',
      'description': 'The AI learns from your interactions and feedback, continuously refining its recommendations to better understand your unique preferences.',
      'icon': FontAwesomeIcons.chartLine,
      'color': Colors.pinkAccent.shade400,
    },
    {
      'title': 'TIME EFFICIENCY',
      'description': 'Spend less time sifting through incompatible profiles. Our AI streamlines the discovery process to bring you quality connections.',
      'icon': FontAwesomeIcons.hourglassHalf,
      'color': Colors.greenAccent.shade400,
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundNebulaController,
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaBackgroundPainter(
                    _backgroundNebulaAnimation,
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
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
                Colors.cyanAccent,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _orbGlowAnimation,
                isSmallScreen ? 0.7 : 1.5,
                Colors.pinkAccent,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : (isMediumScreen ? 60 : 100),
              vertical: isSmallScreen ? 40 : (isMediumScreen ? 60 : 80),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedGlowText(
                  text: 'The Portal to Deeper Connection',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isSmallScreen ? 30 : (isMediumScreen ? 50 : 60),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  glowColorTween: ColorTween(
                    begin: Colors.blueAccent.shade700,
                    end: Colors.greenAccent.shade700,
                  ),
                  blurRadius: isSmallScreen ? 20 : 40,
                  animationDuration: const Duration(seconds: 5),
                  animationCurve: Curves.easeInOutQuad,
                ),
                SizedBox(height: isSmallScreen ? 30 : 60),
                Text(
                  'Your journey to a truly compatible match begins here. Discover how our advanced AI transforms dating.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isSmallScreen ? 16 : 20,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 40 : 80),

                // AI Insights Section
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isSmallScreen ? 20 : 40,
                    runSpacing: isSmallScreen ? 20 : 40,
                    children: _aiInsights.asMap().entries.map<Widget>((entry) { // <-- FIX APPLIED HERE
                      final index = entry.key;
                      final data = entry.value;
                      return InsightCrystal(
                        title: data['title'] as String,
                        description: data['description'] as String,
                        icon: data['icon'] as IconData,
                        baseColor: data['color'] as Color,
                        isSmallScreen: isSmallScreen,
                        staggerDelay: index.toDouble(),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 60 : 100),

                // Login/Signup Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
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
                          fontSize: isSmallScreen ? 22 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 30),
                      SizedBox(
                        width: isSmallScreen ? double.infinity : 300,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 15 : 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: isSmallScreen ? 18 : 22, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                      SizedBox(
                        width: isSmallScreen ? double.infinity : 300,
                        child: OutlinedButton(
                          onPressed: () => context.go('/signup'), // Corrected route to signup
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 15 : 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: isSmallScreen ? 18 : 22, color: Colors.deepPurpleAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 40 : 80),

                // Footer Links
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeTransition(
                    opacity: _textSparkleAnimation, // Reuse existing animation
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isSmallScreen ? 16 : 24,
                          runSpacing: isSmallScreen ? 8 : 12,
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
                        SizedBox(height: isSmallScreen ? 10 : 20),
                        Text(
                          '© 2025 Blind AI Dating.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white.withOpacity(0.5),
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