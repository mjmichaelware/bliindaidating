// lib/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _errorMessage;

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

  Future<void> _attemptSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError('Please fill in both email and password.');
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
      );

      if (response.user != null) {
        debugPrint('User registered successfully with Supabase: ${response.user!.email}');
        if (mounted) {
          context.go('/profile_setup');
        }
      } else if (response.session == null && response.user == null) {
        // This case indicates email verification is required
        _showError('Registration successful! Please check your email to verify your account.');
      } else if (response.user == null && response.session != null) {
        // This case implies user was created but session handling might need review
        _showError('Account created, but could not log in automatically. Please log in.');
      }
    } on AuthException catch (e) {
      debugPrint('Supabase Auth error during signup: ${e.message}');
      _showError('Registration failed: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                    color: Colors.deepPurple.shade900.withAlpha((255 * 0.8).round()),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.4).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/DrawKit Vector Illustration Love & Dating (2).svg',
                        height: isSmall ? 120 : 150,
                        semanticsLabel: 'Sign up illustration',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Forge Your Cosmic Connection',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _inputField(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
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
                      GlowingButton(
                        text: 'Manifest My Destiny',
                        icon: Icons.control_point_duplicate,
                        onPressed: _isLoading
                            ? null // Fixed: onPressed should be null when disabled for GlowingButton
                            : _attemptSignUp,
                        gradientColors: [Colors.purple.shade700, Colors.red.shade600],
                        disabled: _isLoading, // Fixed: Added disabled parameter for GlowingButton
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Already Forged Your Path? Enter Here',
                          style: TextStyle(color: Colors.white.withAlpha((255 * 0.85).round())),
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