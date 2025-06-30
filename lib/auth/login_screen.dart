// lib/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW: Supabase import
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_svg/flutter_svg.dart'; // For SvgPicture.asset

import 'package:bliindaidating/shared/glowing_button.dart'; // Assuming this is correct
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart'; // Assuming this is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _errorMessage;
  bool _isLoading = false; // Added for loading state

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    setState(() {
      _isLoading = true; // Set loading state
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password.'); // Updated message
      setState(() { _isLoading = false; }); // Reset loading state
      return;
    }

    try {
      // --- Supabase Authentication: Sign In ---
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('User logged in successfully with Supabase: ${response.user!.email}');
        if (mounted) {
          context.go('/home'); // Navigate to the home screen on successful login
        }
      } else {
        // This case might happen if no user is returned but no explicit error
        _showError('Login failed. Please check your credentials.');
      }
    } on AuthException catch (e) {
      // Handle Supabase Auth specific errors
      debugPrint('Supabase Auth error during login: ${e.message}');
      _showError('Login failed: ${e.message}');
    } catch (e) {
      // Handle any other unexpected errors
      debugPrint('Unexpected error during login: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    _shakeController.forward(from: 0);
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade900.withAlpha((255 * 0.8).round()), // withAlpha
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.4).round()), // withAlpha
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/DrawKit Vector Illustration Love & Dating (1).svg', // Example SVG
                        height: isSmall ? 120 : 150,
                        semanticsLabel: 'Login illustration',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enter the Cosmic Gateway',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _inputField(
                        label: 'Email Address', // Updated label
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        label: 'Password', // Updated label
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscure: true,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 30),
                      GlowingButton(
                        text: 'Login to My Cosmos',
                        icon: Icons.login,
                        onPressed: _isLoading
                            ? () {} // Provide an empty function when loading
                            : _attemptLogin,
                        gradientColors: [Colors.blue.shade700, Colors.cyan.shade600],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/signup');
                        },
                        child: Text(
                          'New to the galaxy? Sign Up',
                          style: TextStyle(color: Colors.white.withAlpha((255 * 0.85).round())), // withAlpha
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          debugPrint('Forgot password clicked (Supabase handles this via email)');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())), // withAlpha
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
