// lib/widgets/animated_orb_background.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/app_constants.dart';
import 'dart:math' as math;

class AnimatedOrbBackground extends StatefulWidget {
  const AnimatedOrbBackground({super.key});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Longer duration for subtle movement
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color primaryOrbColor = isDarkMode ? AppConstants.secondaryColor.withOpacity(0.3) : AppConstants.lightSecondaryColor.withOpacity(0.3);
    final Color secondaryOrbColor = isDarkMode ? AppConstants.primaryColor.withOpacity(0.2) : AppConstants.lightPrimaryColor.withOpacity(0.2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OrbPainter(
            animationValue: _controller.value,
            primaryOrbColor: primaryOrbColor,
            secondaryOrbColor: secondaryOrbColor,
          ),
          child: Container(), // Empty container as the background
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double animationValue;
  final Color primaryOrbColor;
  final Color secondaryOrbColor;

  _OrbPainter({
    required this.animationValue,
    required this.primaryOrbColor,
    required this.secondaryOrbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Orb 1: Primary color, moves subtly
    final paint1 = Paint()..color = primaryOrbColor;
    final double radius1 = size.width * 0.4 * (0.8 + 0.2 * math.sin(animationValue * 2 * math.pi)); // Pulsating effect
    final double offsetX1 = centerX + math.cos(animationValue * 2 * math.pi) * size.width * 0.1;
    final double offsetY1 = centerY + math.sin(animationValue * 2 * math.pi) * size.height * 0.1;
    canvas.drawCircle(Offset(offsetX1, offsetY1), radius1, paint1);

    // Orb 2: Secondary color, moves in opposite direction or different pattern
    final paint2 = Paint()..color = secondaryOrbColor;
    final double radius2 = size.width * 0.3 * (0.7 + 0.3 * math.cos(animationValue * 2 * math.pi + math.pi / 2)); // Different pulsation
    final double offsetX2 = centerX + math.sin(animationValue * 2 * math.pi) * size.width * 0.15;
    final double offsetY2 = centerY - math.cos(animationValue * 2 * math.pi) * size.height * 0.15;
    canvas.drawCircle(Offset(offsetX2, offsetY2), radius2, paint2);

    // Add a third, smaller orb for more dynamism
    final paint3 = Paint()..color = primaryOrbColor.withOpacity(0.15);
    final double radius3 = size.width * 0.2 * (0.6 + 0.4 * math.sin(animationValue * 2 * math.pi * 0.7));
    final double offsetX3 = centerX - math.cos(animationValue * 2 * math.pi * 0.5) * size.width * 0.2;
    final double offsetY3 = centerY + math.sin(animationValue * 2 * math.pi * 0.5) * size.height * 0.2;
    canvas.drawCircle(Offset(offsetX3, offsetY3), radius3, paint3);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.primaryOrbColor != primaryOrbColor ||
           oldDelegate.secondaryOrbColor != secondaryOrbColor;
  }
}