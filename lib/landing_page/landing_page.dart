import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            Colors.white.withOpacity(0.1 + animation.value * 0.1),
            Colors.white.withOpacity(0.0),
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

  const NexusGateway({
    super.key,
    required this.onTap,
    required this.globalOrbGlowAnimation,
    required this.portalActivateAnimation,
  });

  @override
  State<NexusGateway> createState() => _NexusGatewayState();
}

class _NexusGatewayState extends State<NexusGateway> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
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
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
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
              child: Container(
                width: currentSize,
                height: currentSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(Colors.purpleAccent.withOpacity(0.8), Colors.redAccent.withOpacity(0.9), glowFactor)!,
                      Color.lerp(Colors.deepPurple.shade900.withOpacity(0.7), Colors.orange.shade900.withOpacity(0.8), glowFactor)!,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
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
                    color: Colors.white.withOpacity(0.3 + 0.4 * hoverFactor + 0.2 * glowFactor),
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
                      color: Colors.white.withOpacity(0.8 + 0.2 * hoverFactor + 0.1 * glowFactor),
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

// --- Insight Crystal Widget (Refactored) ---
class InsightCrystal extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color baseColor;
  final bool isSmallScreen;
  final double staggerDelay;

  const InsightCrystal({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
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
      opacity: _appearAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_appearAnimation),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(32),
          constraints: BoxConstraints(
            maxWidth: widget.isSmallScreen ? MediaQuery.of(context).size.width * 0.9 : 480.0,
            minHeight: widget.isSmallScreen ? 250 : 300,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                widget.baseColor.withOpacity(0.7),
                widget.baseColor.withOpacity(0.5),
                Color.lerp(widget.baseColor, Colors.white, 0.3)!.withOpacity(0.6),
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
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                widget.icon,
                color: Colors.white.withOpacity(0.9),
                size: widget.isSmallScreen ? 60 : 80,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.isSmallScreen ? 18 : 22,
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
            final Color baseColor = Colors.white.withOpacity(0.7);

            return Container(
              padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? 10 : 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1 * hoverFactor + 0.03 * glowFactor),
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

  final List<Map<String, dynamic>> _truthSpheres = [
    {
      'title': 'AUTHENTICITY',
      'description': 'Connect deeply, beyond superficial glances. Our AI focuses on who you truly are.',
      'icon': FontAwesomeIcons.seedling,
      'color': Colors.redAccent.shade400,
    },
    {
      'title': 'INTUITION',
      'description': 'Advanced algorithms find your perfect echo, based on values, passions, and dreams.',
      'icon': FontAwesomeIcons.brain,
      'color': Colors.orangeAccent.shade400,
    },
    {
      'title': 'DEPTH',
      'description': 'Discover compatible minds and spirits. Looks may fade, but true connection lasts.',
      'icon': FontAwesomeIcons.infinity,
      'color': Colors.yellowAccent.shade400,
    },
    {
      'title': 'CLARITY',
      'description': 'Tired of endless swiping? We bring meaningful connections directly to you.',
      'icon': FontAwesomeIcons.lightbulb,
      'color': Colors.lightGreenAccent.shade400,
    },
    {
      'title': 'JOURNEY',
      'description': 'Our goal is to move you from matching to meaningful in-person experiences, faster.',
      'icon': FontAwesomeIcons.compass,
      'color': Colors.blueAccent.shade400,
    },
    {
      'title': 'TRUST',
      'description': 'We protect your data with cutting-edge security. Your journey is safe with us.',
      'icon': FontAwesomeIcons.lock,
      'color': Colors.indigoAccent.shade400,
    },
    {
      'title': 'HARMONY',
      'description': 'Join a supportive community, get insights, and thrive in your dating journey.',
      'icon': FontAwesomeIcons.handshakeAngle,
      'color': Colors.purpleAccent.shade400,
    },
  ];

  @override
  void initState() {
    super.initState();

    _globalFadeInController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
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
      _globalFadeInController.forward();
    });
  }

  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
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
          FadeTransition(
            opacity: _globalFadeInAnimation,
            child: ScaleTransition(
              scale: _globalFadeInAnimation.drive(Tween<double>(begin: 0.9, end: 1.0)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double horizontalPadding = isSmallScreen ? 20 : (isMediumScreen ? 60 : 100);
                  final double verticalPadding = isSmallScreen ? 40 : (isMediumScreen ? 60 : 80);

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
                            AnimatedGlowText(
                              text: 'Blind AI Dating',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isSmallScreen ? 45 : (isMediumScreen ? 70 : 90),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: isSmallScreen ? 3.0 : 6.0,
                              ),
                              glowColorTween: ColorTween(
                                begin: Colors.redAccent.shade700,
                                end: Colors.cyanAccent.shade700,
                              ),
                              blurRadius: isSmallScreen ? 25 : 50,
                              animationDuration: const Duration(seconds: 5),
                              animationCurve: Curves.easeInOutQuad,
                            ),
                            SizedBox(height: isSmallScreen ? 40 : (isMediumScreen ? 80 : 120)),
                            NexusGateway(
                              onTap: () => _enterPortal(context),
                              globalOrbGlowAnimation: _orbGlowAnimation,
                              portalActivateAnimation: _portalActivateAnimation,
                            ),
                            SizedBox(height: isSmallScreen ? 60 : (isMediumScreen ? 100 : 150)),
                            Column(
                              children: [
                                AnimatedGlowText(
                                  text: 'Tired of Echoes? Craving Genuine Connection?',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 26 : (isMediumScreen ? 40 : 55),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  glowColorTween: ColorTween(
                                    begin: Colors.pinkAccent.shade400,
                                    end: Colors.orangeAccent.shade400,
                                  ),
                                  blurRadius: isSmallScreen ? 15 : 30,
                                  animationDuration: const Duration(seconds: 4),
                                  animationCurve: Curves.easeInOutSine,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 24),
                                AnimatedGlowText(
                                  text: 'Step into a quantum universe where true understanding ignites destiny. Our AI sees beyond the fleeting, matching hearts, not just profiles.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: isSmallScreen ? 16 : (isMediumScreen ? 20 : 25),
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
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
                            SizedBox(height: isSmallScreen ? 60 : (isMediumScreen ? 100 : 150)),
                            Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: isSmallScreen ? 24 : 60,
                                runSpacing: isSmallScreen ? 24 : 60,
                                children: _truthSpheres.asMap().entries.map<Widget>((entry) { // <--- FIX APPLIED HERE for List<Widget>
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
                            SizedBox(height: isSmallScreen ? 80 : (isMediumScreen ? 120 : 180)),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FadeTransition(
                                opacity: _globalFadeInAnimation,
                                child: Column(
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: isSmallScreen ? 16 : 24,
                                      runSpacing: isSmallScreen ? 8 : 12,
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
                    ),
                  );
                },
              ),
            ),
          ),
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
                            Colors.white.withOpacity(_portalActivateAnimation.value),
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