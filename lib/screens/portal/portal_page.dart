// lib/screens/portal/portal_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For context.go
import 'dart:math' as math; // For mathematical operations like random numbers
import 'package:flutter_svg/flutter_svg.dart'; // REQUIRED for SvgPicture.asset

// Importing public custom painters from LandingPage for consistent background
import 'package:bliindaidating/landing_page/landing_page.dart'; // Contains NebulaBackgroundPainter and ParticleFieldPainter

// Corrected import paths for info screens
import 'package:bliindaidating/screens/info/about_us_screen.dart';
import 'package:bliindaidating/screens/info/privacy_screen.dart';
import 'package:bliindaidating/screens/info/terms_screen.dart';
import 'package:bliindaidating/screens/main/home_screen.dart'; // Import for navigation to home screen


// Make PortalPage a StatefulWidget to manage text controllers and animations (Firebase auth removed)
class PortalPage extends StatefulWidget {
  const PortalPage({super.key});

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> with TickerProviderStateMixin {
  // Text controllers for email and password input fields (now for demonstration only)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State to hold any error messages (now for demonstration only, no actual Firebase errors)
  String? _errorMessage;

  // REMOVED: FirebaseAuth instance.

  // Animation Controllers for cosmic background effects
  late AnimationController _backgroundNebulaController;
  late Animation<double> _backgroundNebulaAnimation;
  late AnimationController _orbGlowController;
  late Animation<double> _orbGlowAnimation;
  late AnimationController _textSparkleController;
  late Animation<double> _textSparkleAnimation;

  // Background Particle Data (copied from LandingPage for consistency)
  final List<Offset> _nebulaParticles = [];
  final List<Offset> _deepSpaceParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // REMOVED: FirebaseAuth.instance initialization

    // Initialize animation controllers for cosmic background
    _backgroundNebulaController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _backgroundNebulaAnimation = CurvedAnimation(parent: _backgroundNebulaController, curve: Curves.linear);

    _orbGlowController = AnimationController(vsync: this, duration: const Duration(seconds: 5), reverseDuration: const Duration(seconds: 4))..repeat(reverse: true);
    _orbGlowAnimation = CurvedAnimation(parent: _orbGlowController, curve: Curves.easeInOutSine);

    _textSparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6), reverseDuration: const Duration(seconds: 5))..repeat(reverse: true);
    _textSparkleAnimation = CurvedAnimation(parent: _textSparkleController, curve: Curves.easeInOutCirc);

    // Particle Generation
    _generateParticles(100, _nebulaParticles);
    _generateParticles(80, _deepSpaceParticles);
  }

  // Helper method to generate particles
  void _generateParticles(int count, List<Offset> particleList) {
    for (int i = 0; i < count; i++) {
      particleList.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _backgroundNebulaController.dispose();
    _orbGlowController.dispose();
    _textSparkleController.dispose();
    super.dispose();
  }

  // Helper method for navigation using MaterialPageRoute for info links
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Function to handle user login (now for demonstration, no actual Firebase auth)
  Future<void> _signIn() async {
    // Simulate login for demonstration purposes
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = null; // Clear previous messages
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    // Simulate a successful login for any non-empty credentials
    if (email.isNotEmpty && password.isNotEmpty) {
      // In a real app, this is where Firebase authentication would happen
      print('Attempting to sign in with email: $email, password: $password');
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      // Assuming successful login for demonstration
      if (mounted) {
        context.go('/home'); // Navigate to the home screen
      }
    } else {
      // This else block is mostly for completeness if further complex validation were added
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    // REMOVED: Firebase.apps.isEmpty check.

    return Scaffold(
      appBar: AppBar(
        // REPLACED: Original Text title with SVG asset
        title: SvgPicture.asset(
          'assets/svg/DrawKit Vector Illustration Love & Dating (3).svg',
          height: 40, // Adjust height as needed to fit the app bar
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), // Optional: tint SVG white for visibility
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent to show background effects
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true, // Allows body to extend behind app bar for full background effect
      body: Stack(
        children: [
          // Background effects (copied from LandingPage for consistency)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundNebulaController,
              builder: (context, child) {
                // Using the now public NebulaBackgroundPainter
                return CustomPaint(
                  painter: NebulaBackgroundPainter( // No underscore
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
              // Using the now public ParticleFieldPainter
              painter: ParticleFieldPainter( // No underscore
                _nebulaParticles,
                _textSparkleAnimation,
                isSmallScreen ? 1.0 : 2.0,
                Colors.cyanAccent,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              // Using the now public ParticleFieldPainter
              painter: ParticleFieldPainter( // No underscore
                _deepSpaceParticles,
                _orbGlowAnimation,
                isSmallScreen ? 0.7 : 1.5,
                Colors.pinkAccent,
              ),
            ),
          ),

          // Main content on top of the background
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Information section
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Blind AI Dating', // Corrected spelling
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
                          // Info navigation buttons (NO DUPLICATES)
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
                    color: Colors.white.withOpacity(0.1),
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
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.5)),
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
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.purpleAccent,
                          ),
                          if (_errorMessage != null) // Display error message if present
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
                            onPressed: _signIn, // Call the sign-in function
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
                              context.go('/signup'); // Navigate to sign up screen
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
                  const SizedBox(height: 30), // Spacing before the new section

                  // NEW: "Our Approach" Section
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // Center content
                        children: [
                          // Hero Image (SVG)
                          SvgPicture.asset(
                            'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg',
                            height: isSmallScreen ? 150 : 200, // Responsive height
                            colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn), // Light tint for visibility
                          ),
                          const SizedBox(height: 20),

                          // Title and Subheading
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

                          // Explanatory Paragraph
                          Text(
                            'Blind AI Dating is built on the belief that true connections blossom from shared values and genuine understanding, not fleeting glances. Our advanced AI carefully matches you based on deep compatibility, encouraging conversations that lead to promising real-life dates, rather than endless swiping. We focus on getting you off the app and into a relationship that lasts.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // Testimonials Section Title
                          Text(
                            'What Our Users Will Say:',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Simulated Testimonials
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
                  const SizedBox(height: 30), // Spacing after the new section
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build a testimonial card
  Widget _buildTestimonialCard(BuildContext context, String quote, String author) {
    return Card(
      color: Colors.deepPurple.shade700.withOpacity(0.4), // Slightly different shade for testimonials
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