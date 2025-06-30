// lib/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
  // Removed _confirmController as per request: "Email and password is all it should be asking for"
  // final _confirmController = TextEditingController(); // REMOVED

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
    // Removed dispose for _confirmController
    // _confirmController.dispose(); // REMOVED
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _attemptSignUp() async {
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    // Removed confirm variable
    // final confirm = _confirmController.text.trim(); // REMOVED

    if (email.isEmpty || pass.isEmpty) { // Updated validation to remove confirm check
      _showError('Please fill in both email and password.'); // Updated error message
      return;
    }

    // Removed password confirmation check as _confirmController is removed
    // if (pass != confirm) { // REMOVED
    //   _showError('Secret keys must align. They do not match.'); // REMOVED
    //   return; // REMOVED
    // } // REMOVED

    try {
      // Firebase Authentication: Create User
      // Ensure Firebase.initializeApp() is called before this point in your app's lifecycle.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      
      if (mounted) {
        // Navigate to the profile setup screen upon successful registration
        GoRouter.of(context).go('/profile_setup');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors with updated messages
      _showError(switch (e.code) {
        'weak-password' => 'Your password is too weak. Please choose a stronger one.', // Updated message
        'email-already-in-use' => 'An account with this email already exists. Try logging in instead.', // Updated message
        'invalid-email' => 'The email address format is invalid.', // Updated message
        _ => 'An unexpected error occurred during registration. Please try again.', // Generic error
      });
    } catch (e) {
      // Handle any other unexpected errors
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
                    color: Colors.deepPurple.shade900.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.4),
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
                        label: 'Email Address', // Changed label
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        label: 'Password', // Changed label
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscure: true,
                      ),
                      // Removed the Confirm Password input field
                      // const SizedBox(height: 20), // REMOVED
                      // _inputField( // REMOVED
                      //   label: 'Confirm Your Secret Key', // REMOVED
                      //   icon: Icons.key_outlined, // REMOVED
                      //   controller: _confirmController, // REMOVED
                      //   obscure: true, // REMOVED
                      // ), // REMOVED
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
                        onPressed: _attemptSignUp,
                        gradientColors: [Colors.purple.shade700, Colors.red.shade600],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => GoRouter.of(context).go('/login'),
                        child: Text(
                          'Already Forged Your Path? Enter Here',
                          style: TextStyle(color: Colors.white.withOpacity(0.85)),
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
