// lib/landing_page/landing_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG assets
import 'package:provider/provider.dart'; // Import for ThemeController

// Local imports for AppConstants and new widgets
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/animated_tagline.dart';
import 'package:bliindaidating/widgets/enter_here_text.dart';
import 'package:bliindaidating/widgets/scroll_hint.dart';
import 'package:bliindaidating/widgets/help_dialog.dart';
import 'package:bliindaidating/widgets/theme_toggle.dart';
import 'package:bliindaidating/widgets/sparkle_effect.dart';
import 'package:bliindaidating/widgets/glowing_aura.dart';

// Import info screens as they are navigated to from this page
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';

// --- Custom Painter for Dynamic Nebula Background ---
class NebulaBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  NebulaBackgroundPainter(this.animation, this.primaryColor, this.secondaryColor)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final color1 = Color.lerp(primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.6), animation.value)!;
    final color2 = Color.lerp(secondaryColor.withOpacity(0.4), primaryColor.withOpacity(0.6), animation.value)!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          center: Alignment(math.sin(animation.value * math.pi * 2) * 0.5, math.cos(animation.value * math.pi * 2) * 0.5),
          radius: 0.8 + 0.2 * animation.value,
        ).createShader(Offset.zero & size),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppConstants.textColor.withOpacity(0.1 + animation.value * 0.1),
            AppConstants.textColor.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7),
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0 * animation.value),
    );
  }

  @override
  bool shouldRepaint(covariant NebulaBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// --- Custom Painter for Dynamic Particle Field ---
class ParticleFieldPainter extends CustomPainter {
  final List<Offset> particles;
  final Animation<double> animation;
  final double maxRadius;
  final Color baseColor;

  ParticleFieldPainter(this.particles, this.animation, this.maxRadius, this.baseColor)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withOpacity(0.3 + 0.7 * animation.value)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxRadius * animation.value * 0.5);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 5;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 5;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);
      canvas.drawCircle(currentPosition, maxRadius * animation.value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleFieldPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// --- Animated Glow Text Widget (Refactored) ---
// Note: This is similar to AnimatedTagline but kept separate for distinct usage
// and potential future divergence in animation behavior.
class AnimatedGlowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final ColorTween glowColorTween;
  final double blurRadius;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedGlowText({
    super.key,
    required this.text,
    required this.style,
    required this.glowColorTween,
    this.blurRadius = 10.0,
    this.animationDuration = const Duration(seconds: 4),
    this.animationCurve = Curves.easeInOutSine,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, value, child) {
        final Color currentGlowColor = glowColorTween.evaluate(AlwaysStoppedAnimation(value))!;
        final double currentBlur = blurRadius * value;
        return Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            shadows: [
              BoxShadow(
                color: currentGlowColor.withOpacity(0.5 + 0.5 * value),
                blurRadius: currentBlur,
                offset: const Offset(0, 0), // Centered shadow for glow
              ),
            ],
          ),
        );
      },
      onEnd: () {
        // This trick makes TweenAnimationBuilder repeat
        (context as Element).markNeedsBuild();
      },
    );
  }
}

// --- Nexus Gateway Widget (Refactored) ---
class NexusGateway extends StatefulWidget {
  final VoidCallback onTap;
  final Animation<double> globalOrbGlowAnimation;
  final Animation<double> portalActivateAnimation;
  final Function(Offset, Size) onHoverSparkle; // Callback for sparkle effect

  const NexusGateway({
    super.key,
    required this.onTap,
    required this.globalOrbGlowAnimation,
    required this.portalActivateAnimation,
    required this.onHoverSparkle,
  });

  @override
  State<NexusGateway> createState() => _NexusGatewayState();
}

class _NexusGatewayState extends State<NexusGateway> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  Offset _lastHoverPosition = Offset.zero; // To track hover position for sparkles

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 768;

    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Use appropriate colors based on theme
    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color primaryColorShade900 = isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade900;
    final Color secondaryColorShade900 = isDarkMode ? AppConstants.secondaryColorShade900 : AppConstants.lightSecondaryColorShade900;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;


    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onHover: (event) {
        // Trigger sparkle effect on hover movement
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          _lastHoverPosition = renderBox.globalToLocal(event.position);
          widget.onHoverSparkle(_lastHoverPosition, renderBox.size);
        }
      },
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTapDown: (details) {
          // Trigger sparkle effect on tap down
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            widget.onHoverSparkle(renderBox.globalToLocal(details.globalPosition), renderBox.size);
          }
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.globalOrbGlowAnimation, _hoverAnimation]),
          builder: (context, child) {
            final double glowFactor = widget.globalOrbGlowAnimation.value;
            final double hoverFactor = _hoverAnimation.value;

            final double baseSize = isSmallScreen ? size.width * 0.7 : (size.width < 1200 ? 350 : 450);
            final double currentSize = baseSize * (1.0 + 0.05 * hoverFactor + 0.02 * glowFactor);
            final double currentBlur = 80.0 * (0.5 + 0.5 * glowFactor) + 20 * hoverFactor;
            final double currentSpread = 20.0 * (0.5 + 0.5 * glowFactor) + 10 * hoverFactor;

            return ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.0).animate(widget.portalActivateAnimation),
              child: GlowingAura( // Wrap with GlowingAura for pulsing effect
                glowColor: primaryColor.withOpacity(0.7),
                maxBlurRadius: currentBlur * 0.5,
                maxSpreadRadius: currentSpread * 0.5,
                duration: const Duration(seconds: 2),
                child: Container(
                  width: currentSize,
                  height: currentSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(primaryColor.withOpacity(0.8), secondaryColor.withOpacity(0.9), glowFactor)!,
                        Color.lerp(primaryColorShade900.withOpacity(0.7), secondaryColorShade900.withOpacity(0.8), glowFactor)!,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.9 * glowFactor + 0.5 * hoverFactor),
                        blurRadius: currentBlur,
                        spreadRadius: currentSpread,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.7 * glowFactor + 0.4 * hoverFactor),
                        blurRadius: currentBlur * 0.7,
                        spreadRadius: currentSpread * 0.7,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    border: Border.all(
                      color: textColor.withOpacity(0.3 + 0.4 * hoverFactor + 0.2 * glowFactor),
                      width: 3 + 2 * hoverFactor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'MANIFEST YOUR DESTINY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isSmallScreen ? 20 : (size.width < 1200 ? 28 : 36),
                        fontWeight: FontWeight.w900,
                        color: textHighEmphasis.withOpacity(0.8 + 0.2 * hoverFactor + 0.1 * glowFactor),
                        letterSpacing: isSmallScreen ? 2 : 3,
                        shadows: [
                          Shadow(
                            color: textHighEmphasis.withOpacity(0.5 * glowFactor + 0.3 * hoverFactor),
                            blurRadius: 10 * glowFactor + 5 * hoverFactor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Insight Crystal Widget (Refactored) ---
class InsightCrystal extends StatefulWidget {
  final String title;
  final String description;
  final String svgAssetPath; // Changed from IconData to String for SVG
  final Color baseColor; // This will now be a "hint" color for the gradient
  final bool isSmallScreen;
  final double staggerDelay;

  const InsightCrystal({
    super.key,
    required this.title,
    required this.description,
    required this.svgAssetPath, // Updated parameter
    required this.baseColor,
    required this.isSmallScreen,
    required this.staggerDelay,
  });

  @override
  State<InsightCrystal> createState() => _InsightCrystalState();
}

class _InsightCrystalState extends State<InsightCrystal> with SingleTickerProviderStateMixin {
  late AnimationController _appearController;
  late Animation<double> _appearAnimation;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _appearAnimation = CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack);
    Future.delayed(Duration(milliseconds: (widget.staggerDelay * 200).toInt()), () {
      if (mounted) { // Ensure widget is still mounted before starting animation
        _appearController.forward();
      }
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Dynamic colors based on theme
    final Color dialogBackgroundColor = isDarkMode ? AppConstants.dialogBackgroundColor : AppConstants.lightDialogBackgroundColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color borderColor = isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor;

    return FadeTransition(
      opacity: _appearAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_appearAnimation),
        child: Container(
          margin: const EdgeInsets.all(AppConstants.spacingSmall),
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          constraints: BoxConstraints(
            maxWidth: widget.isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : 480.0,
            minHeight: widget.isSmallScreen ? 250 : 300,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusExtraLarge),
            gradient: LinearGradient(
              colors: [
                Color.lerp(dialogBackgroundColor, widget.baseColor, 0.4)!.withOpacity(0.7),
                Color.lerp(dialogBackgroundColor, widget.baseColor, 0.2)!.withOpacity(0.5),
                Color.lerp(dialogBackgroundColor, textColor, 0.1)!.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.baseColor.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use SvgPicture.asset for SVG icons
              SvgPicture.asset(
                widget.svgAssetPath,
                colorFilter: ColorFilter.mode(textHighEmphasis.withOpacity(0.9), BlendMode.srcIn), // Apply theme color
                width: widget.isSmallScreen ? 60 : 80,
                height: widget.isSmallScreen ? 60 : 80,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: textHighEmphasis,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 18 : 22,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Footer Navigation Link Widget (Refactored) ---
class FooterNavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final Animation<double> animation;

  const FooterNavLink({
    super.key,
    required this.label,
    required this.onTap,
    required this.isSmallScreen,
    required this.animation,
  });

  @override
  State<FooterNavLink> createState() => _FooterNavLinkState();
}

class _FooterNavLinkState extends State<FooterNavLink> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color primaryColor = AppConstants.primaryColor; // Use primary for hover glow

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, widget.animation]),
          builder: (context, child) {
            final double glowFactor = widget.animation.value;
            final double hoverFactor = _hoverAnimation.value;
            final Color baseColor = textColor.withOpacity(0.7);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium, vertical: AppConstants.spacingExtraSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1 * hoverFactor + 0.03 * glowFactor),
                    blurRadius: 8 * hoverFactor + 4 * glowFactor,
                    spreadRadius: 2 * hoverFactor + 1 * glowFactor,
                    offset: const Offset(0, 0),
                  ),
                ],
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isSmallScreen ? 12 : 14,
                  color: Color.lerp(baseColor, textHighEmphasis, hoverFactor * 0.8 + glowFactor * 0.2),
                  letterSpacing: 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- The Reimagined Landing Page (Stateful Widget) ---
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _globalFadeInController;
  late Animation<double> _globalFadeInAnimation;

  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;

  late AnimationController _orbGlowController;
  late Animation<double> _orbGlowAnimation;

  late AnimationController _textSparkleController;
  late Animation<double> _textSparkleAnimation;

  late AnimationController _portalActivateController;
  late Animation<double> _portalActivateAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  // List to hold active sparkle effects
  final List<Widget> _activeSparkleEffects = [];

  // Updated _truthSpheres to use SVG asset paths from AppConstants
  final List<Map<String, dynamic>> _truthSpheres = [
    {
      'title': 'AUTHENTICITY',
      'description': 'Connect deeply, beyond superficial glances. Our AI focuses on who you truly are.',
      'svgAssetPath': AppConstants.svgLoveAndDating1, // Using SVG asset
      'color': AppConstants.primaryColor,
    },
    {
      'title': 'INTUITION',
      'description': 'Advanced algorithms find your perfect echo, based on values, passions, and dreams.',
      'svgAssetPath': AppConstants.svgLoveAndDating2, // Using SVG asset
      'color': AppConstants.secondaryColor,
    },
    {
      'title': 'DEPTH',
      'description': 'Discover compatible minds and spirits. Looks may fade, but true connection lasts.',
      'svgAssetPath': AppConstants.svgLoveAndDating4, // Using SVG asset
      'color': AppConstants.tertiaryColor,
    },
    {
      'title': 'CLARITY',
      'description': 'Tired of endless swiping? We bring meaningful connections directly to you.',
      'svgAssetPath': AppConstants.svgLoveAndDating7, // Using SVG asset
      'color': AppConstants.complementaryColor1,
    },
    {
      'title': 'JOURNEY',
      'description': 'Our goal is to move you from matching to meaningful in-person experiences, faster.',
      'svgAssetPath': AppConstants.svgLoveAndDating8, // Using SVG asset
      'color': AppConstants.complementaryColor2,
    },
    {
      'title': 'TRUST',
      'description': 'We protect your data with cutting-edge security. Your journey is safe with us.',
      'svgAssetPath': AppConstants.svgLoveAndDating9, // Using SVG asset
      'color': AppConstants.complementaryColor3,
    },
    {
      'title': 'HARMONY',
      'description': 'Join a supportive community, get insights, and thrive in your dating journey.',
      'svgAssetPath': AppConstants.svgLoveAndDating11, // Using SVG asset
      'color': AppConstants.complementaryColor4,
    },
  ];

  @override
  void initState() {
    super.initState();

    _globalFadeInController = AnimationController(vsync: this, duration: AppConstants.animationDurationExtraLong);
    _globalFadeInAnimation = CurvedAnimation(parent: _globalFadeInController, curve: Curves.easeOutQuart);

    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _orbGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 5), reverseDuration: const Duration(seconds: 4))..repeat(reverse: true);
    _orbGlowAnimation = CurvedAnimation(parent: _orbGlowController, curve: Curves.easeInOutSine);

    _textSparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6), reverseDuration: const Duration(seconds: 5))..repeat(reverse: true);
    _textSparkleAnimation = CurvedAnimation(parent: _textSparkleController, curve: Curves.easeInOutCirc);

    _portalActivateController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _portalActivateAnimation = CurvedAnimation(parent: _portalActivateController, curve: Curves.easeOutCubic);

    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _globalFadeInController.forward();
      }
    });
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  /// Handles triggering sparkle effects on the CTA button.
  void _handleCtaSparkle(Offset localPosition, Size buttonSize) {
    // Get the global position of the button itself
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Calculate the global position where the sparkle should appear
    // This is the local position within the button, offset by the button's global top-left
    final Offset sparkleOrigin = renderBox.localToGlobal(localPosition);

    final sparkle = SparkleEffect(
      key: ValueKey(DateTime.now().microsecondsSinceEpoch), // Unique key for each sparkle burst
      origin: sparkleOrigin,
      color: AppConstants.textHighEmphasis, // Sparkle color
      numberOfSparkles: 8,
      duration: const Duration(milliseconds: 500),
      maxRadius: 3.0,
      spreadRadius: 20.0,
    );

    setState(() {
      _activeSparkleEffects.add(sparkle);
    });

    // Remove the sparkle effect after its duration
    Future.delayed(sparkle.duration, () {
      if (mounted) {
        setState(() {
          _activeSparkleEffects.remove(sparkle);
        });
      }
    });
  }


  @override
  void dispose() {
    _globalFadeInController.dispose();
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    _portalActivateController.dispose();
    super.dispose();
  }

  void _enterPortal(BuildContext context) {
    if (_portalActivateController.isAnimating) return;

    _portalActivateController.forward().then((_) {
      context.go('/portal_hub');
    });
  }

  void _navigateToInfo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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
          // --- Background Elements ---
          _buildBackgroundNebula(isDarkMode),
          _buildParticleField(isSmallScreen, isDarkMode),

          // --- Main Content (Fade In) ---
          FadeTransition(
            opacity: _globalFadeInAnimation,
            child: ScaleTransition(
              scale: _globalFadeInAnimation.drive(Tween<double>(begin: 0.9, end: 1.0)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double horizontalPadding = isSmallScreen ? AppConstants.spacingMedium : (isMediumScreen ? AppConstants.spacingExtraLarge : AppConstants.spacingXXL);
                  final double verticalPadding = isSmallScreen ? AppConstants.spacingLarge : (isMediumScreen ? AppConstants.spacingExtraLarge : AppConstants.spacingXXL);

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - (verticalPadding * 2)),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // --- Header Section ---
                            _buildHeaderSection(),
                            SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : AppConstants.spacingXXXL),

                            // --- Main Title and Tagline ---
                            AnimatedGlowText(
                              text: AppConstants.appName,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isSmallScreen ? 45 : (isMediumScreen ? 70 : 90),
                                fontWeight: FontWeight.w900,
                                color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                                letterSpacing: isSmallScreen ? 3.0 : 6.0,
                              ),
                              glowColorTween: ColorTween(
                                begin: isDarkMode ? AppConstants.primaryColorShade700 : AppConstants.lightPrimaryColorShade700,
                                end: isDarkMode ? AppConstants.secondaryColorShade700 : AppConstants.lightSecondaryColorShade700,
                              ),
                              blurRadius: isSmallScreen ? 25 : 50,
                              animationDuration: const Duration(seconds: 5),
                              animationCurve: Curves.easeInOutQuad,
                            ),
                            const SizedBox(height: AppConstants.spacingMedium), // Space between title and tagline
                            AnimatedTagline(
                              text: AppConstants.landingTagline, // New tagline from AppConstants
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isSmallScreen ? AppConstants.fontSizeMedium : AppConstants.fontSizeLarge,
                                fontWeight: FontWeight.w500,
                                color: (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.8),
                                letterSpacing: 1.0,
                              ),
                              glowColorTween: ColorTween(
                                begin: isDarkMode ? AppConstants.secondaryColorShade400 : AppConstants.lightSecondaryColorShade400,
                                end: isDarkMode ? AppConstants.primaryColorShade400 : AppConstants.lightPrimaryColorShade400,
                              ),
                              blurRadius: isSmallScreen ? 8 : 15,
                              animationDuration: const Duration(seconds: 4),
                              animationCurve: Curves.easeOut,
                            ),
                            SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : (isMediumScreen ? AppConstants.spacingXXXL : AppConstants.spacingXXXL * 1.5)),

                            // --- Nexus Gateway (CTA) ---
                            NexusGateway(
                              onTap: () => _enterPortal(context),
                              globalOrbGlowAnimation: _orbGlowAnimation,
                              portalActivateAnimation: _portalActivateAnimation,
                              onHoverSparkle: _handleCtaSparkle, // Pass callback for sparkles
                            ),
                            const SizedBox(height: AppConstants.spacingSmall), // Small space for "Enter Here"
                            const EnterHereText(), // "Enter Here" text
                            SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : (isMediumScreen ? AppConstants.spacingXXXL : AppConstants.spacingXXXL * 1.5)),

                            // --- Core Value Proposition / Insights ---
                            Column(
                              children: [
                                AnimatedGlowText(
                                  text: AppConstants.landingHeadline1,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 26 : (isMediumScreen ? 40 : 55),
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                                    height: 1.2,
                                  ),
                                  glowColorTween: ColorTween(
                                    begin: isDarkMode ? AppConstants.primaryColorShade400 : AppConstants.lightPrimaryColorShade400,
                                    end: isDarkMode ? AppConstants.secondaryColorShade400 : AppConstants.lightSecondaryColorShade400,
                                  ),
                                  blurRadius: isSmallScreen ? 15 : 30,
                                  animationDuration: const Duration(seconds: 4),
                                  animationCurve: Curves.easeInOutSine,
                                ),
                                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
                                AnimatedGlowText(
                                  text: AppConstants.landingHeadline2,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 20 : 25),
                                    color: (isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor).withOpacity(0.7),
                                    height: 1.5,
                                  ),
                                  glowColorTween: ColorTween(
                                    begin: isDarkMode ? AppConstants.secondaryColorShade400 : AppConstants.lightSecondaryColorShade400,
                                    end: isDarkMode ? AppConstants.primaryColorShade400 : AppConstants.lightPrimaryColorShade400,
                                  ),
                                  blurRadius: isSmallScreen ? 10 : 20,
                                  animationDuration: const Duration(seconds: 5),
                                  animationCurve: Curves.easeOut,
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? AppConstants.spacingXXL : (isMediumScreen ? AppConstants.spacingXXXL : AppConstants.spacingXXXL * 1.5)),

                            // --- Insight Crystals Section ---
                            Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXXL,
                                runSpacing: isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXXL,
                                children: _truthSpheres.asMap().entries.map<Widget>((entry) {
                                  final index = entry.key;
                                  final data = entry.value;
                                  return InsightCrystal(
                                    title: data['title'] as String,
                                    description: data['description'] as String,
                                    svgAssetPath: data['svgAssetPath'] as String, // Use SVG asset path
                                    baseColor: data['color'] as Color,
                                    isSmallScreen: isSmallScreen,
                                    staggerDelay: index.toDouble(),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? AppConstants.spacingXXXL : (isMediumScreen ? AppConstants.spacingXXXL * 1.5 : AppConstants.spacingXXXL * 2)),

                            // --- Footer Section ---
                            _buildFooterSection(isSmallScreen, isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- Floating Sparkle Effects (on top of content) ---
          ..._activeSparkleEffects,

          // --- Floating Action Buttons (Help and Scroll Hint) ---
          _buildFloatingButtons(isSmallScreen),

          // --- Portal Activation Overlay ---
          IgnorePointer(
            ignoring: _portalActivateController.status != AnimationStatus.forward,
            child: AnimatedBuilder(
              animation: _portalActivateAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _portalActivateAnimation.value,
                  child: Transform.scale(
                    scale: _portalActivateAnimation.value * 2.5,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            (isDarkMode ? Colors.white : Colors.black).withOpacity(_portalActivateAnimation.value),
                            (isDarkMode ? Colors.white : Colors.black).withOpacity(_portalActivateAnimation.value * 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build the background nebula painter.
  Widget _buildBackgroundNebula(bool isDarkMode) {
    return Positioned.fill(
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
    );
  }

  /// Helper method to build the particle field painters.
  Widget _buildParticleField(bool isSmallScreen, bool isDarkMode) {
    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(
            painter: ParticleFieldPainter(
              _nebulaParticles,
              _textSparkleAnimation,
              isSmallScreen ? 1.0 : 2.0,
              isDarkMode ? AppConstants.secondaryColor.withOpacity(0.8) : AppConstants.secondaryColor.withOpacity(0.5),
            ),
          ),
          CustomPaint(
            painter: ParticleFieldPainter(
              _deepSpaceParticles,
              _orbGlowAnimation,
              isSmallScreen ? 0.7 : 1.5,
              isDarkMode ? AppConstants.primaryColor.withOpacity(0.8) : AppConstants.primaryColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build the header section (e.g., ThemeToggle).
  Widget _buildHeaderSection() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ThemeToggle(), // Theme toggle button
          ],
        ),
      ),
    );
  }

  /// Helper method to build the footer section (About Us, Privacy, Terms).
  Widget _buildFooterSection(bool isSmallScreen, bool isDarkMode) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeTransition(
        opacity: _globalFadeInAnimation,
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge,
              runSpacing: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium,
              children: [
                FooterNavLink(
                  label: 'About Us',
                  onTap: () => _navigateToInfo(context, const AboutUsScreen()),
                  isSmallScreen: isSmallScreen,
                  animation: _textSparkleAnimation,
                ),
                FooterNavLink(
                  label: 'Privacy Policy',
                  onTap: () => _navigateToInfo(context, const PrivacyScreen()),
                  isSmallScreen: isSmallScreen,
                  animation: _textSparkleAnimation,
                ),
                FooterNavLink(
                  label: 'Terms of Service',
                  onTap: () => _navigateToInfo(context, const TermsScreen()),
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
    );
  }

  /// Helper method to build floating action buttons (Help and Scroll Hint).
  Widget _buildFloatingButtons(bool isSmallScreen) {
    return Positioned(
      bottom: AppConstants.spacingLarge,
      right: AppConstants.spacingLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HelpButton(), // Help icon button
          SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
          const ScrollHint(), // Scroll hint arrow
        ],
      ),
    );
  }
}
