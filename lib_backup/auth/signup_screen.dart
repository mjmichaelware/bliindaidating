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
  final _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Moved _formKey declaration here

  bool _isLoading = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('SignUpScreen: initState - navigated to /signup');
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
    _confirmPasswordController.dispose();
    _shakeController.dispose();
    debugPrint('SignUpScreen: dispose');
    super.dispose();
  }

  // Client-side password validation
  String? _validatePassword(String? value) {
    if (value == null || (value ?? []).isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    return null; // Password is valid
  }

  Future<void> _attemptSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if ((email ?? []).isEmpty) {
      _showError('Please enter your email address.');
      setState(() { _isLoading = false; });
      return;
    }

    final passwordValidationError = _validatePassword(password);
    if (passwordValidationError != null) {
      _showError(passwordValidationError);
      setState(() { _isLoading = false; });
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match. Please re-enter.');
      setState(() { _isLoading = false; });
      return;
    }

    debugPrint('SignUpScreen: Attempting signup for email: $email');
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        debugPrint('SignUpScreen: User registered and logged in successfully: ${response.user!.email}');
        if (mounted) {
          debugPrint('SignUpScreen: Navigating to /profile_setup');
          context.go('/profile_setup');
        }
      } else if (response.user != null && response.session == null) {
        debugPrint('SignUpScreen: User registered, but no session. Email confirmation might be unexpectedly ON. User: ${response.user?.id}');
        _showError('Registration successful! Please try logging in. If issues persist, check your email for a verification link.');
        if (mounted) {
          context.go('/login');
        }
      } else {
        debugPrint('SignUpScreen: Unexpected Supabase signup response. User: ${response.user?.id}, Session: ${response.session?.accessToken != null ? 'Exists' : 'Null'}'); // Corrected to accessToken
        _showError('Account created, but an unexpected issue occurred. Please try logging in.');
        if (mounted) {
          context.go('/login');
        }
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
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Inter'),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorStyle: const TextStyle(fontFamily: 'Inter'),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size?.width < 600;

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
                  child: Form(
                    key: _formKey, // Use the declared _formKey
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
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'your.email@example.com',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email cannot be empty.';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _inputField(
                          label: 'Password',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscure: true,
                          hintText: '8+ chars, incl. A-Z, a-z, 0-9',
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 20),
                        _inputField(
                          label: 'Confirm Password',
                          icon: Icons.lock_reset_outlined,
                          controller: _confirmPasswordController,
                          obscure: true,
                          hintText: 'Re-enter your password',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirmation password cannot be empty.';
                            }
                            if (value != _passwordController.text.trim()) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
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
                          onPressed: _isLoading ? null : () {
                            if (_formKey.currentState!.validate()) { // Correctly access _formKey
                              _attemptSignUp();
                            }
                          },
                          gradientColors: [Colors.purple.shade700, Colors.red.shade600],
                          disabled: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            debugPrint('SignUpScreen: Navigating to /login from TextButton');
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
          ),
        ],
      ),
    );
  }
}