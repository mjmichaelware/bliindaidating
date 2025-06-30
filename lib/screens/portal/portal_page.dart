// lib/screens/portal/portal_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
// REMOVED: import 'package:flutter/foundation.dart'; // unnecessary_import

import 'package:bliindaidating/landing_page/landing_page.dart';

import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';


class PortalPage extends StatefulWidget {
  const PortalPage({super.key});

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _orbGlowController;
  late Animation<double> _orbGlowAnimation;
  late AnimationController _textSparkleController;
  late Animation<double> _textSparkleAnimation;

  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

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
    _emailController.dispose();
    _passwordController.dispose();
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    if (email.isNotEmpty && password.isNotEmpty) {
      debugPrint('Simulating sign in with email: $email, password: $password');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.go('/home');
      }
    } else {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/svg/DrawKit Vector Illustration Love & Dating (3).svg',
          height: 40,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          semanticsLabel: 'Blind AI Dating Logo',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    color: Colors.white.withAlpha((255 * 0.1).round()),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Blind AI Dating',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Discover meaningful connections based on shared interests and values, powered by AI.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _navigateTo(context, const AboutUsScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('About Us', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _navigateTo(context, const PrivacyScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _navigateTo(context, const TermsScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade400,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login/Signup Form Section
                  Card(
                    color: Colors.white.withAlpha((255 * 0.1).round()),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(color: Colors.white.withAlpha((255 * 0.5).round())),
                              filled: true,
                              fillColor: Colors.white.withAlpha((255 * 0.05).round()),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withAlpha((255 * 0.5).round())),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.purpleAccent,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(color: Colors.white.withAlpha((255 * 0.5).round())),
                              filled: true,
                              fillColor: Colors.white.withAlpha((255 * 0.05).round()),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withAlpha((255 * 0.5).round())),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.purpleAccent,
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 30),

                          // Login Button
                          ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            child: Text(
                              'Log In',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/signup');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            child: Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // NEW: "Our Approach" Section
                  Card(
                    color: Colors.white.withAlpha((255 * 0.1).round()),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg',
                            height: isSmallScreen ? 150 : 200,
                            colorFilter: ColorFilter.mode(Colors.white70.withAlpha((255 * 0.7).round()), BlendMode.srcIn),
                            semanticsLabel: 'Two people lying down and laughing together',
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Our Approach: Go On Your Last First Date',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'We’re love scientists, engineering meaningful connections.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.deepPurpleAccent,
                                  fontStyle: FontStyle.italic,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Blind AI Dating is built on the belief that true connections blossom from shared values and genuine understanding, not fleeting glances. Our advanced AI carefully matches you based on deep compatibility, encouraging conversations that lead to promising real-life dates, rather than endless swiping. We focus on getting you off the app and into a relationship that lasts.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          Text(
                            'What Our Users Will Say:',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          _buildTestimonialCard(
                            context,
                            '"I never thought I\'d find someone who truly understood me. Blind AI Dating connected us on a level no other app could. It really was my last first date!"',
                            '— Alex R., Found True Connection',
                          ),
                          const SizedBox(height: 15),
                          _buildTestimonialCard(
                            context,
                            '"The conversations felt so natural and deep from the start. Thanks to Blind AI Dating, we\'re building a future together."',
                            '— Jamie L., Engaged!',
                          ),
                          const SizedBox(height: 15),
                          _buildTestimonialCard(
                            context,
                            '"Finally, an app that prioritizes substance over surface. The AI insights were spot on, leading me to someone I genuinely adore."',
                            '— Chris V., Authentic Match',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, String quote, String author) {
    return Card(
      color: Colors.deepPurple.shade700.withAlpha((255 * 0.4).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              quote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              author,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
