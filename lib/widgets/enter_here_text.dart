// lib/widgets/enter_here_text.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For AppConstants.textColor and font

/// A small, subtly animated text hint to guide users to click the CTA.
/// It features a pulsing fade animation to draw attention without being intrusive.
class EnterHereText extends StatefulWidget {
  const EnterHereText({super.key});

  @override
  State<EnterHereText> createState() => _EnterHereTextState();
}

class _EnterHereTextState extends State<EnterHereText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Pulsing duration
    )..repeat(reverse: true); // Repeat with reverse for a pulsing effect
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation.drive(Tween<double>(begin: 0.4, end: 1.0)), // Fade from 40% to 100% opacity
      child: Text(
        'ENTER HERE',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: AppConstants.fontSizeSmall, // Very small font size
          fontWeight: FontWeight.w500,
          color: AppConstants.textColor.withOpacity(0.8), // Subtle white
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
