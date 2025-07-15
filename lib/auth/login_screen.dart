// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Still needed for AuthException
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // Import Provider

import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';
import 'package:bliindaidating/services/auth_service.dart'; // Import your AuthService

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('LoginScreen: initState - navigated to /login');
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
    debugPrint('LoginScreen: dispose');
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) { // Ensure widget is still in the tree before calling setState or accessing context
      setState(() => _errorMessage = message);
      _shakeController.forward(from: 0);
      debugPrint('LoginScreen: Displaying error: $message');
    }
  }

  Future<void> _attemptLogin() async {
    // Prevent multiple clicks while an operation is in progress
    if (_isLoading) {
      debugPrint('LoginScreen: _attemptLogin called but already loading. Ignoring.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
      debugPrint('LoginScreen: Setting _isLoading to true.');
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password.');
      setState(() { _isLoading = false; }); // Must reset _isLoading here
      debugPrint('LoginScreen: Email or password empty.');
      return;
    }

    try {
      debugPrint('LoginScreen: Accessing AuthService...');
      // Access the AuthService via Provider
      final authService = Provider.of<AuthService>(context, listen: false);

      debugPrint('LoginScreen: Calling authService.signIn for email: $email');
      // Await the signIn method from AuthService
      await authService.signIn(email: email, password: password);

      debugPrint('LoginScreen: authService.signIn completed. GoRouter redirect should handle navigation.');
      // NO MANUAL NAVIGATION HERE (e.g., context.go('/home')).
      // The GoRouter's redirect logic (in main.dart) will automatically
      // detect the logged-in state change via AuthService's notifyListeners
      // and navigate to the appropriate screen (e.g., dashboard or profile setup).
    } on AuthException catch (e) {
      debugPrint('LoginScreen: Supabase Auth error during login: ${e.message}');
      _showError('Login failed: ${e.message}');
    } catch (e, stack) { // Catch all other exceptions, including synchronous ones
      debugPrint('LoginScreen: UNEXPECTED ERROR during login: $e\n$stack');
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      // Always reset loading state when the operation finishes, regardless of success or failure.
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
          debugPrint('LoginScreen: Setting _isLoading to false in finally block.');
        });
      } else {
        debugPrint('LoginScreen: Widget no longer mounted, cannot set _isLoading to false.');
      }
    }
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return TextField(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen: build method called. _isLoading: $_isLoading');
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
                        'assets/svg/DrawKit Vector Illustration Love & Dating (1).svg',
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
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'your.email@example.com',
                      ),
                      const SizedBox(height: 20),
                      _inputField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscure: true,
                        hintText: 'Your secret password',
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
                        onPressed: _isLoading ? null : _attemptLogin, // Button disabled when _isLoading is true
                        gradientColors: [Colors.blue.shade700, Colors.cyan.shade600],
                        disabled: _isLoading, // Pass disabled state to GlowingButton
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          debugPrint('LoginScreen: Navigating to /signup from TextButton');
                          context.go('/signup');
                        },
                        child: Text(
                          'New to the galaxy? Sign Up',
                          style: TextStyle(color: Colors.white.withAlpha((255 * 0.85).round())),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          debugPrint('LoginScreen: Forgot password clicked');
                          context.go('/forgot-password'); // Ensure this navigates correctly
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
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