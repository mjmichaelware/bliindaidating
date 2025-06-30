// lib/landing_page/landing_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'dart:math' as math; // For mathematical operations like random numbers and sine waves
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For awesome icons

// Importing your existing info screens as destinations.
// PATHS CONFIRMED CORRECT with your `tree`: lib/screens/info/
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';
// CRITICAL: Correct import for YOUR existing PortalPage (login/signup hub).
// This NEW LandingPage will navigate to it using context.go('/portal_hub').
// PATH CONFIRMED CORRECT with your `tree`: lib/screens/portal/
import 'package:bliindaidating/screens/portal/portal_page.dart';

/// --- Custom Painter for Dynamic Nebula Background ---
/// Creates a swirling, ethereal nebula effect using radial gradients and blur filters.
/// This contributes to the "living background" and cosmic game intro feel.
/// Made public (removed '_') so PortalPage can reuse it.
class NebulaBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  NebulaBackgroundPainter(this.animation, this.primaryColor, this.secondaryColor)
      : super(repaint: animation); // Repaints whenever the animation value changes

  @override
  void paint(Canvas canvas, Size size) {
    // Determine dynamic colors for the nebula based on animation value
    final color1 = Color.lerp(primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.6), animation.value)!;
    final color2 = Color.lerp(secondaryColor.withOpacity(0.4), primaryColor.withOpacity(0.6), animation.value)!;

    // First, draw a large, soft radial gradient for the main nebula cloud
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          center: Alignment(math.sin(animation.value * math.pi * 2) * 0.5, math.cos(animation.value * math.pi * 2) * 0.5), // Center shifts
          radius: 0.8 + 0.2 * animation.value, // Radius pulses
        ).createShader(Offset.zero & size),
    );

    // Second, draw a smaller, brighter, and more blurred radial gradient for a core
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.1 + animation.value * 0.1),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7), // Center shifts
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0 * animation.value), // Add significant blur
    );
  }

  @override
  bool shouldRepaint(covariant NebulaBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation; // Only repaint if animation changes
  }
}

/// --- Custom Painter for Dynamic Particle Field ---
/// Renders thousands of tiny, twinkling particles that subtly drift and pulse,
/// creating a sense of depth and a star-field effect.
/// Made public (removed '_') so PortalPage can reuse it.
class ParticleFieldPainter extends CustomPainter {
  final List<Offset> particles;
  final Animation<double> animation; // For pulsing and drifting
  final double maxRadius;
  final Color baseColor;

  ParticleFieldPainter(this.particles, this.animation, this.maxRadius, this.baseColor)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the particles with dynamic opacity and blur
    final paint = Paint()
      ..color = baseColor.withOpacity(0.3 + 0.7 * animation.value) // Opacity pulsates
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxRadius * animation.value * 0.5); // Subtle glow pulse

    // Iterate through and draw each particle
    for (var i = 0; i < particles.length; i++) {
      // Calculate particle position, adding a subtle drift based on animation
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 5;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 5;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);

      canvas.drawCircle(currentPosition, maxRadius * animation.value, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleFieldPainter oldDelegate) {
    return oldDelegate.animation != animation; // Repaint only when animation changes
  }
}

/// --- Custom Widget for Animated Glowing Text ---
/// Creates text that subtly glows and pulses, drawing attention and adding a magical feel.
/// Uses a TweenAnimationBuilder for implicit animation of glow properties.
class _AnimatedGlowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final ColorTween glowColorTween; // Tween for dynamic glow color
  final double blurRadius;
  final double offset;
  final Duration animationDuration;
  final Curve animationCurve;

  const _AnimatedGlowText({
    required this.text,
    required this.style,
    required this.glowColorTween,
    this.blurRadius = 10.0,
    this.offset = 2.0,
    this.animationDuration = const Duration(seconds: 4),
    this.animationCurve = Curves.easeInOutSine,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0), // Animates from 0 to 1
      duration: animationDuration,
      curve: animationCurve,
      // Repeat the animation in reverse to create a continuous pulse
      builder: (context, value, child) {
        // Calculate current glow color and blur radius based on animation value
        final Color currentGlowColor = glowColorTween.evaluate(AlwaysStoppedAnimation(value))!;
        final double currentBlur = blurRadius * value;

        return Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            shadows: [
              BoxShadow(
                color: currentGlowColor.withOpacity(0.5 + 0.5 * value), // Opacity also pulses
                blurRadius: currentBlur,
                offset: Offset(offset, offset),
              ),
            ],
          ),
        );
      },
      // Set to repeat for continuous animation
      // Note: TweenAnimationBuilder animates once. For repeating, it's usually driven by a parent controller.
      // This implementation uses a manual restart for simplicity in a self-contained widget.
      onEnd: () {
        // This is a common trick to make TweenAnimationBuilder repeat
        // by implicitly rebuilding and restarting its animation.
        // For more controlled repeating, a parent AnimationController is better.
      },
    );
  }
}

/// --- Truth Crystal Widget ---
/// Represents a core value proposition as an animated, glowing crystal.
/// Now features only staggered appearance, but no floating or rotation for readability.
class _InsightCrystal extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color baseColor; // Base color for the crystal's vibrant theme
  final bool isSmallScreen;
  final double staggerDelay; // For staggered appearance

  const _InsightCrystal({
    required this.title,
    required this.description,
    required this.icon,
    required this.baseColor,
    required this.isSmallScreen,
    required this.staggerDelay,
  });

  @override
  State<_InsightCrystal> createState() => _InsightCrystalState();
}

class _InsightCrystalState extends State<_InsightCrystal> with SingleTickerProviderStateMixin {
  late AnimationController _appearController; // Controls the crystal's entrance animation
  late Animation<double> _appearAnimation;

  @override
  void initState() {
    super.initState();

    _appearController = AnimationController(
      vsync: this, // vsync provided by TickerProviderStateMixin
      duration: const Duration(milliseconds: 1200), // Smooth appearance duration
    );
    _appearAnimation = CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack);

    // Start the appearance animation after a delay based on staggerDelay
    Future.delayed(Duration(milliseconds: (widget.staggerDelay * 200).toInt()), () {
      _appearController.forward();
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _appearAnimation, // Crystal fades in
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_appearAnimation), // Slides up
        child: Container(
          margin: const EdgeInsets.all(8), // Spacing between crystals
          padding: const EdgeInsets.all(32), // Significantly increased internal padding
          // MODIFIED: Increased maxWidth significantly for better readability and to force more rows.
          // On small screens, take up most of the width (e.g., 90%) to force single column.
          // On larger screens, allow for 1 or 2 columns based on total screen width.
          constraints: BoxConstraints(
            // On small screens, force nearly full width to ensure single column.
            // On larger screens, set a generous max width to allow 1 or 2 columns.
            maxWidth: widget.isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : 480.0,
            // Ensure a minimum height to accommodate content comfortably, especially when text might wrap
            minHeight: widget.isSmallScreen ? 250 : 300,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25), // Rounded crystal shape
            // Vibrant, shifting gradient for crystal effect
            gradient: LinearGradient(
              colors: [
                widget.baseColor.withOpacity(0.7),
                widget.baseColor.withOpacity(0.5),
                Color.lerp(widget.baseColor, Colors.white, 0.3)!.withOpacity(0.6), // Highlight color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.baseColor.withOpacity(0.5), // Subtle shadow without pulsating
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2), // Static border
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // MODIFIED: Increased icon size for larger crystals
              FaIcon(
                widget.icon,
                color: Colors.white.withOpacity(0.9),
                size: widget.isSmallScreen ? 60 : 80, // Much larger icons
              ),
              const SizedBox(height: 16), // Increased vertical spacing inside crystal
              // MODIFIED: Increased font sizes for readability
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 28 : 36, // Much larger text
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12), // Increased vertical spacing inside crystal
              // MODIFIED: Increased font sizes for readability
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 18 : 22, // Much larger text
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Nexus Gateway Widget (Interactive Login/Sign Up) ---
/// The main interactive element, designed as a pulsating, glowing portal.
/// Features intense visual feedback on hover and a dramatic activation animation on tap.
class _NexusGateway extends StatefulWidget {
  final VoidCallback onTap;
  final Animation<double> globalOrbGlowAnimation; // For shared pulsing
  final Animation<double> portalActivateAnimation; // For dramatic exit

  const _NexusGateway({
    required this.onTap,
    required this.globalOrbGlowAnimation,
    required this.portalActivateAnimation,
  });

  @override
  State<_NexusGateway> createState() => _NexusGatewayState();
}

class _NexusGatewayState extends State<_NexusGateway> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController; // Controls local hover animation
  late Animation<double> _hoverAnimation;

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

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(), // Animate on mouse enter
      onExit: (_) => _hoverController.reverse(), // Animate on mouse exit
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.globalOrbGlowAnimation, _hoverAnimation]), // Listen to multiple animations
          builder: (context, child) {
            // Combine global pulse and local hover effects for dynamic appearance
            final double glowFactor = widget.globalOrbGlowAnimation.value;
            final double hoverFactor = _hoverAnimation.value;

            // Determine dynamic size and glow intensity
            final double baseSize = isSmallScreen ? size.width * 0.7 : (size.width < 1200 ? 350 : 450);
            final double currentSize = baseSize * (1.0 + 0.05 * hoverFactor + 0.02 * glowFactor); // Scales slightly on hover/pulse
            final double currentBlur = 80.0 * (0.5 + 0.5 * glowFactor) + 20 * hoverFactor;
            final double currentSpread = 20.0 * (0.5 + 0.5 * glowFactor) + 10 * hoverFactor;

            return ScaleTransition(
              // Scale down dramatically when portal activates
              scale: Tween<double>(begin: 1.0, end: 0.0).animate(widget.portalActivateAnimation),
              child: Container(
                width: currentSize,
                height: currentSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Dynamic, kaleidoscopic radial gradient for the portal effect
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(Colors.purpleAccent.withOpacity(0.8), Colors.redAccent.withOpacity(0.9), glowFactor)!,
                      Color.lerp(Colors.deepPurple.shade900.withOpacity(0.7), Colors.orange.shade900.withOpacity(0.8), glowFactor)!,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    // Multiple shadows for a layered, vibrant glow
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.9 * glowFactor + 0.5 * hoverFactor),
                      blurRadius: currentBlur,
                      spreadRadius: currentSpread,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.7 * glowFactor + 0.4 * hoverFactor),
                      blurRadius: currentBlur * 0.7,
                      spreadRadius: currentSpread * 0.7,
                      offset: const Offset(0, 0),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3 + 0.4 * hoverFactor + 0.2 * glowFactor), // Pulsating, brightening border
                    width: 3 + 2 * hoverFactor,
                  ),
                ),
                child: Center(
                  child: Text(
                    'MANIFEST YOUR DESTINY', // Prominent, action-oriented text
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isSmallScreen ? 20 : (size.width < 1200 ? 28 : 36),
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.8 + 0.2 * hoverFactor + 0.1 * glowFactor), // Text brightens on hover/pulse
                      letterSpacing: isSmallScreen ? 2 : 3,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.5 * glowFactor + 0.3 * hoverFactor),
                          blurRadius: 10 * glowFactor + 5 * hoverFactor,
                        ),
                      ],
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

/// --- Footer Navigation Link Widget ---
/// Custom button for footer links with subtle glow on hover and pulse.
class _FooterNavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final Animation<double> animation; // Shared animation for subtle glow pulse

  const _FooterNavLink({
    required this.label,
    required this.onTap,
    required this.isSmallScreen,
    required this.animation,
  });

  @override
  State<_FooterNavLink> createState() => _FooterNavLinkState();
}

class _FooterNavLinkState extends State<_FooterNavLink> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController; // Controls local hover effect
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
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(), // Animate when mouse enters
      onExit: (_) => _hoverController.reverse(), // Animate when mouse exits
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, widget.animation]), // Listen to both animations
          builder: (context, child) {
            final double glowFactor = widget.animation.value; // Global pulse factor
            final double hoverFactor = _hoverAnimation.value; // Local hover factor
            final Color baseColor = Colors.white.withOpacity(0.7);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? 10 : 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent, // Background transparent until hover
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1 * hoverFactor + 0.03 * glowFactor), // Subtle glow on hover/pulse
                    blurRadius: 8 * hoverFactor + 4 * glowFactor,
                    spreadRadius: 2 * hoverFactor + 1 * glowFactor,
                  ),
                ],
                border: Border.all(
                  color: Colors.transparent, // No border by default
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: widget.isSmallScreen ? 12 : 14,
                  // Text color shifts brighter on hover/glow
                  color: Color.lerp(baseColor, Colors.white, hoverFactor * 0.8 + glowFactor * 0.2),
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

/// --- The Reimagined Landing Page (Stateful Widget) ---
/// This widget orchestrates all the layers, animations, and interactive elements
/// to create a cinematic and emotionally engaging landing experience.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  // --- Animation Controllers ---
  // Orchestrate the timing and progression of various visual effects.
  late AnimationController _globalFadeInController; // Controls the initial page fade-in
  late Animation<double> _globalFadeInAnimation;

  late AnimationController _backgroundNebulaController; // Controls the swirling background nebula
  late Animation<double> _backgroundNebulaAnimation;

  late AnimationController _orbGlowController; // Controls the main interactive orb's pulsing glow
  late Animation<double> _orbGlowAnimation;

  late AnimationController _textSparkleController; // Controls subtle text shimmering and pulsing
  late Animation<double> _textSparkleAnimation;

  // Removed _truthSphereFloatController as per request (crystals no longer float)

  late AnimationController _portalActivateController; // Controls the dramatic transition on portal entry
  late Animation<double> _portalActivateAnimation; // Scales/fades out elements

  // --- Background Particle Data ---
  // Stores positions for thousands of particles for a dynamic star-field effect.
  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random(); // Random number generator for particle positions

  // --- Core Value Propositions (Insight Crystals) ---
  // Data for the interactive "truth crystals," each with a distinct color from the rainbow.
  final List<Map<String, dynamic>> _truthSpheres = [
    {
      'title': 'AUTHENTICITY',
      'description': 'Connect deeply, beyond superficial glances. Our AI focuses on who you truly are.',
      'icon': FontAwesomeIcons.seedling, // Represents growth, organic connection
      'color': Colors.redAccent.shade400, // Vibrant red
    },
    {
      'title': 'INTUITION',
      'description': 'Advanced algorithms find your perfect echo, based on values, passions, and dreams.',
      'icon': FontAwesomeIcons.brain, // Represents AI intelligence
      'color': Colors.orangeAccent.shade400, // Vibrant orange
    },
    {
      'title': 'DEPTH',
      'description': 'Discover compatible minds and spirits. Looks may fade, but true connection lasts.',
      'icon': FontAwesomeIcons.infinity, // Represents endless possibility, lasting connection
      'color': Colors.yellowAccent.shade400, // Vibrant yellow
    },
    {
      'title': 'CLARITY',
      'description': 'Tired of endless swiping? We bring meaningful connections directly to you.',
      'icon': FontAwesomeIcons.lightbulb, // Represents insight, illumination
      'color': Colors.lightGreenAccent.shade400, // Vibrant green
    },
    {
      'title': 'JOURNEY',
      'description': 'Our goal is to move you from matching to meaningful in-person experiences, faster.',
      'icon': FontAwesomeIcons.compass, // Represents guidance, pathfinding
      'color': Colors.blueAccent.shade400, // Vibrant blue
    },
    {
      'title': 'TRUST',
      'description': 'We protect your data with cutting-edge security. Your journey is safe with us.',
      'icon': FontAwesomeIcons.lock, // Represents security, safety
      'color': Colors.indigoAccent.shade400, // Vibrant indigo
    },
    {
      'title': 'HARMONY',
      'description': 'Join a supportive community, get insights, and thrive in your dating journey.',
      'icon': FontAwesomeIcons.handshakeAngle, // Represents community, support
      'color': Colors.purpleAccent.shade400, // Vibrant purple
    },
  ];

  @override
  void initState() {
    super.initState();

    // --- Controller Initialization ---
    _globalFadeInController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _globalFadeInAnimation = CurvedAnimation(parent: _globalFadeInController, curve: Curves.easeOutQuart);

    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat(); // Slow, continuous motion
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _orbGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 5), reverseDuration: const Duration(seconds: 4))..repeat(reverse: true);
    _orbGlowAnimation = CurvedAnimation(parent: _orbGlowController, curve: Curves.easeInOutSine);

    _textSparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6), reverseDuration: const Duration(seconds: 5))..repeat(reverse: true);
    _textSparkleAnimation = CurvedAnimation(parent: _textSparkleController, curve: Curves.easeInOutCirc);

    // Removed _truthSphereFloatController as per request (crystals no longer float)

    _portalActivateController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _portalActivateAnimation = CurvedAnimation(parent: _portalActivateController, curve: Curves.easeOutCubic);

    // --- Particle Generation ---
    _generateParticles(100, _nebulaParticles); // More particles for dense background
    _generateParticles(80, _deepSpaceParticles); // Finer, more distant particles

    // --- Start Initial Animations ---
    // Start the whole page's fade-in after a short, dramatic pause.
    Future.delayed(const Duration(milliseconds: 800), () {
      _globalFadeInController.forward();
    });
  }

  /// Generates random particle positions within a normalized 0-1 range for painting.
  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks, crucial for complex animations.
    _globalFadeInController.dispose();
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    // Removed dispose for _truthSphereFloatController
    _portalActivateController.dispose();
    super.dispose();
  }

  /// --- Navigation to Portal (Login/Signup Hub) ---
  /// Triggers a dramatic animation before navigating, enhancing the "portal" feel.
  void _enterPortal(BuildContext context) {
    if (_portalActivateController.isAnimating) return; // Prevent multiple activations

    // Start the portal activation animation
    _portalActivateController.forward().then((_) {
      // Navigate using GoRouter. THIS IS THE CRITICAL PATH TO YOUR PORTALPAGE.
      // It uses the route name '/portal_hub' which is explicitly defined in the main.dart file.
      context.go('/portal_hub');
    });
  }

  /// Helper for navigating to secondary info screens (About Us, Privacy, Terms).
  /// Uses MaterialPageRoute for simple, direct navigation outside the main GoRouter flow.
  void _navigateToInfo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Define responsive breakpoints for fine-grained control over layout and sizing.
    final bool isSmallScreen = size.width < 600; // Phones
    final bool isMediumScreen = size.width >= 600 && size.width < 1000; // Tablets
    final bool isLargeScreen = size.width >= 1000; // Desktops / Laptops

    return Scaffold(
      // Set a deep, dark background for the cosmic theme.
      backgroundColor: Colors.black, // Starting with true black for deep space
      body: Stack(
        // The Stack allows for complex layering of animated elements.
        children: [
          // Layer 1: Animated Nebula Background
          // This forms the primary, deep-space visual element, constantly shifting.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundNebulaController,
              builder: (context, child) {
                // Now using the public NebulaBackgroundPainter
                return CustomPaint(
                  painter: NebulaBackgroundPainter(
                    _backgroundNebulaAnimation,
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                  ),
                  child: Container(), // Empty container to provide size for painter
                );
              },
            ),
          ),

          // Layer 2: Dynamic Particle Fields
          // Two layers of particles, each with different colors and animations,
          // creating a layered, sparkling star-field effect.
          Positioned.fill(
            child: CustomPaint(
              // Now using the public ParticleFieldPainter
              painter: ParticleFieldPainter(
                _nebulaParticles,
                _textSparkleAnimation, // Uses a text-related animation for its pulse
                isSmallScreen ? 1.0 : 2.0, // Dynamic size based on screen
                Colors.cyanAccent, // Vibrant color
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              // Now using the public ParticleFieldPainter
              painter: ParticleFieldPainter(
                _deepSpaceParticles,
                _orbGlowAnimation, // Uses orb-related animation for its pulse
                isSmallScreen ? 0.7 : 1.5, // Slightly smaller particles
                Colors.pinkAccent, // Different vibrant color
              ),
            ),
          ),

          // Layer 3: Global Fade-In and Slight Scale for Cinematic Entrance
          // All main UI content appears with a smooth, dramatic entrance.
          FadeTransition(
            opacity: _globalFadeInAnimation,
            child: ScaleTransition(
              scale: _globalFadeInAnimation.drive(Tween<double>(begin: 0.9, end: 1.0)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine dynamic padding for responsiveness.
                  final double horizontalPadding = isSmallScreen ? 20 : (isMediumScreen ? 60 : 100);
                  final double verticalPadding = isSmallScreen ? 40 : (isMediumScreen ? 60 : 80);

                  return SingleChildScrollView(
                    // Ensures content can scroll on smaller screens if necessary.
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: ConstrainedBox(
                      // Ensures content takes at least the full screen height for visual impact.
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - (verticalPadding * 2)),
                      child: IntrinsicHeight(
                        // Allows inner widgets to size naturally.
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes space vertically
                          crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                          children: [
                            // --- Company Title: Blind AI Dating ---
                            // This is the bold, prominent, and correctly spelled brand name.
                            // It uses dynamic text sizing and a glowing animation.
                            _AnimatedGlowText(
                              text: 'Blind AI Dating', // Corrected spelling!
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isSmallScreen ? 45 : (isMediumScreen ? 70 : 90),
                                fontWeight: FontWeight.w900, // Extra bold for prominence
                                color: Colors.white, // White text against dark background
                                letterSpacing: isSmallScreen ? 3.0 : 6.0, // Spaced out for grandeur
                              ),
                              // Glow color dynamically shifts for a captivating effect.
                              glowColorTween: ColorTween(
                                begin: Colors.redAccent.shade700,
                                end: Colors.cyanAccent.shade700,
                              ),
                              blurRadius: isSmallScreen ? 25 : 50, // Intense blur for glow
                              animationDuration: const Duration(seconds: 5),
                              animationCurve: Curves.easeInOutQuad,
                            ),

                            SizedBox(height: isSmallScreen ? 40 : (isMediumScreen ? 80 : 120)), // Dynamic spacing

                            // --- The Nexus Gateway (Login/Sign Up) - NOW HIGHER UP ---
                            // Moved to be between the title and the hero message.
                            _NexusGateway(
                              onTap: () => _enterPortal(context), // Activates portal and navigates
                              globalOrbGlowAnimation: _orbGlowAnimation, // Shared pulsing animation
                              portalActivateAnimation: _portalActivateAnimation, // Shared dramatic exit animation
                            ),

                            SizedBox(height: isSmallScreen ? 60 : (isMediumScreen ? 100 : 150)), // Dynamic spacing

                            // --- Hero Message: The Emotional Hook ---
                            // Two lines of emotional copy, each with its own glowing animation,
                            // designed to resonate deeply with the user's desire for connection.
                            Column(
                              children: [
                                _AnimatedGlowText(
                                  text: 'Tired of Echoes? Craving Genuine Connection?',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 26 : (isMediumScreen ? 40 : 55),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2, // Tighter line spacing
                                  ),
                                  // Glow color shifts between warm, inviting tones.
                                  glowColorTween: ColorTween(
                                    begin: Colors.pinkAccent.shade400,
                                    end: Colors.orangeAccent.shade400,
                                  ),
                                  blurRadius: isSmallScreen ? 15 : 30,
                                  animationDuration: const Duration(seconds: 4),
                                  animationCurve: Curves.easeInOutSine,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                _AnimatedGlowText(
                                  text: 'Step into a quantum universe where true understanding ignites destiny. Our AI sees beyond the fleeting, matching hearts, not just profiles.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 20 : 25),
                                    color: Colors.white70,
                                    height: 1.5, // More relaxed line spacing
                                  ),
                                  // Glow color shifts between cool, analytical tones.
                                  glowColorTween: ColorTween(
                                    begin: Colors.cyanAccent.shade400,
                                    end: Colors.lightGreenAccent.shade400,
                                  ),
                                  blurRadius: isSmallScreen ? 10 : 20,
                                  animationDuration: const Duration(seconds: 5),
                                  animationCurve: Curves.easeOut,
                                ),
                              ],
                            ),

                            SizedBox(height: isSmallScreen ? 60 : (isMediumScreen ? 100 : 150)), // Dynamic spacing

                            // --- Truth Crystals (Core Values/Beliefs) ---
                            // An array of animated, glowing crystals, each representing a core value.
                            // They are laid out responsively using Wrap, now larger and stationary.
                            // REMOVED: FittedBox around Wrap
                            Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center, // Centers the wrapped items
                                // MODIFIED: Increased spacing for larger crystals
                                spacing: isSmallScreen ? 24 : 60, // Horizontal spacing (increased for larger boxes)
                                runSpacing: isSmallScreen ? 24 : 60, // Vertical spacing between rows (increased)
                                children: _truthSpheres.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;
                                  // Each crystal is built with staggered appearance and continuous float animation.
                                  return _InsightCrystal(
                                    title: data['title'] as String,
                                    description: data['description'] as String,
                                    icon: data['icon'] as IconData,
                                    baseColor: data['color'] as Color,
                                    isSmallScreen: isSmallScreen,
                                    staggerDelay: index.toDouble(), // Staggered entry
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 80 : (isMediumScreen ? 120 : 180)), // Spacing before footer

                            // --- Footer Navigation Links ---
                            // Consolidated and animated legal/informational links at the bottom.
                            // They glow subtly on hover, maintaining the "alive" UI feel.
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FadeTransition(
                                opacity: _globalFadeInAnimation, // Footer fades in with the rest of content
                                child: Column(
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: isSmallScreen ? 16 : 24,
                                      runSpacing: isSmallScreen ? 8 : 12,
                                      children: [
                                        _FooterNavLink(
                                          label: 'About Us',
                                          onTap: () => _navigateToInfo(context, const AboutUsScreen()),
                                          isSmallScreen: isSmallScreen,
                                          animation: _textSparkleAnimation, // Shared animation for subtle glow
                                        ),
                                        _FooterNavLink(
                                          label: 'Privacy Policy',
                                          onTap: () => _navigateToInfo(context, const PrivacyScreen()),
                                          isSmallScreen: isSmallScreen,
                                          animation: _textSparkleAnimation,
                                        ),
                                        _FooterNavLink(
                                          label: 'Terms of Service',
                                          onTap: () => _navigateToInfo(context, const TermsScreen()),
                                          isSmallScreen: isSmallScreen,
                                          animation: _textSparkleAnimation,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 10 : 20),
                                    Text(
                                      '© 2025 Blind AI Dating.', // Corrected spelling here
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
                    ),
                  );
                },
              ),
            ),
          ),
          // Layer 4: Portal Activation Visual Effect
          // This overlay creates a dramatic light burst effect when the Nexus Gateway is tapped,
          // simulating a warp-speed jump or portal activation.
          IgnorePointer( // Prevents interaction with elements behind it during animation
            ignoring: _portalActivateController.status != AnimationStatus.forward,
            child: AnimatedBuilder(
              animation: _portalActivateAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _portalActivateAnimation.value, // Fades in with animation
                  child: Transform.scale(
                    scale: _portalActivateAnimation.value * 2.5, // Expands rapidly
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        // Radial gradient for a strong light burst from the center
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(_portalActivateAnimation.value), // Bright white center
                            Colors.white.withOpacity(_portalActivateAnimation.value * 0.5),
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
}
