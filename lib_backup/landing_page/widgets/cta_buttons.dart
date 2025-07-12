import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';

class CtaButtons extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  const CtaButtons({
    super.key,
    required this.onLogin,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size?.width < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlowingButton(
          text: 'Log In',
          icon: Icons.login_rounded,
          onPressed: onLogin,
          gradientColors: [
            Colors.red.shade700,
            Colors.deepPurple.shade700,
          ],
          height: isSmallScreen ? 44 : 56,
          width: 140,
        ),
        const SizedBox(width: 20),
        GlowingButton(
          text: 'Sign Up',
          icon: Icons.person_add_rounded,
          onPressed: onSignUp,
          gradientColors: [
            Colors.deepPurple.shade700,
            Colors.indigo.shade500,
          ],
          height: isSmallScreen ? 44 : 56,
          width: 140,
        ),
      ],
    );
  }
}
