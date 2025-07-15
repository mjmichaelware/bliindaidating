// lib/widgets/dashboard_shell/side_menu_background_painter.dart

import 'package:flutter/material.dart';
import 'dart:math' as math; // For math.pi and other math functions

/// Custom Painter for Side Menu Background (Inspired by NebulaBackgroundPainter)
class SideMenuBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Offset> particles;
  final double particleMaxRadius;
  final bool isDrawerMode; // Added to control opacity

  SideMenuBackgroundPainter(
    this.animation,
    this.primaryColor,
    this.secondaryColor,
    this.particles,
    this.particleMaxRadius,
    this.isDrawerMode,
  ) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Main gradient background
    final color1 = Color.lerp(primaryColor.withOpacity(0.4), secondaryColor.withOpacity(0.6), animation.value)!;
    final color2 = Color.lerp(secondaryColor.withOpacity(0.4), primaryColor.withOpacity(0.6), animation.value)!;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient( // Changed to Linear for side menu feel
          colors: [color1, color2, Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    // Secondary subtle glow/nebula effect
    // Adjust opacity for drawer mode to make it less distracting
    final double glowOpacity = isDrawerMode
        ? (0.02 + animation.value * 0.03) // Less intense for drawer
        : (0.05 + animation.value * 0.05); // More intense for persistent
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(glowOpacity), // Using a general light color for glow
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
          center: Alignment(math.cos(animation.value * math.pi) * 0.7, math.sin(animation.value * math.pi) * 0.7),
          radius: 0.2 + 0.1 * animation.value,
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * animation.value),
    );

    // Particles (inspired by ParticleFieldPainter)
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1 + 0.2 * animation.value) // General light color for particles
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleMaxRadius * animation.value * 0.5);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final driftX = math.sin(animation.value * math.pi * 2 + i * 0.1) * 3;
      final driftY = math.cos(animation.value * math.pi * 2 + i * 0.1) * 3;
      final currentPosition = Offset(particle.dx * size.width + driftX, particle.dy * size.height + driftY);
      canvas.drawCircle(currentPosition, particleMaxRadius * animation.value, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SideMenuBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor ||
           oldDelegate.isDrawerMode != isDrawerMode;
  }
}