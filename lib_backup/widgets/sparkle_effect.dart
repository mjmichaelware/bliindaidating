// lib/widgets/sparkle_effect.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:bliindaidating/app_constants.dart'; // For AppConstants colors

/// A custom painter for drawing dynamic sparkle particles.
///
/// This painter creates a visually appealing sparkle effect, often used
/// for micro-interactions like hover or tap feedback.
class SparklePainter extends CustomPainter {
  final List<Offset> sparklePositions;
  final Animation<double> animation;
  final Color color;
  final double maxRadius;

  SparklePainter({
    required this.sparklePositions,
    required this.animation,
    this.color = AppConstants.textHighEmphasis, // Default sparkle color
    this.maxRadius = 5.0,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(animation.value) // Fade out sparkles
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxRadius * (1 - animation.value)); // Blur as they fade

    for (var position in sparklePositions) {
      final currentRadius = maxRadius * animation.value; // Shrink as they fade
      canvas.drawCircle(position, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.sparklePositions != sparklePositions;
  }
}

/// A widget that displays a burst of animated sparkles.
///
/// This widget can be triggered to show a short-lived sparkle effect,
/// useful for micro-interactions on buttons or other interactive elements.
class SparkleEffect extends StatefulWidget {
  final Offset origin; // The center point where sparkles originate
  final int numberOfSparkles;
  final Duration duration;
  final Color color;
  final double maxRadius;
  final double spreadRadius;

  const SparkleEffect({
    super.key,
    required this.origin,
    this.numberOfSparkles = 10,
    this.duration = const Duration(milliseconds: 600),
    this.color = AppConstants.textHighEmphasis,
    this.maxRadius = 5.0,
    this.spreadRadius = 30.0,
  });

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> _sparklePositions = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _generateSparkles();
    _controller.forward(); // Start the sparkle animation
  }

  /// Generates random positions for the sparkles around the origin.
  void _generateSparkles() {
    _sparklePositions = List.generate(widget.numberOfSparkles, (index) {
      final angle = _random.nextDouble() * 2 * math.pi; // Random angle
      final distance = _random.nextDouble() * widget.spreadRadius; // Random distance within spread
      return Offset(
        widget.origin?.dx + distance * math.cos(angle),
        widget.origin?.dy + distance * math.sin(angle),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer( // Make sure the sparkles don't block taps
      child: CustomPaint(
        painter: SparklePainter(
          sparklePositions: _sparklePositions,
          animation: _animation,
          color: widget.color,
          maxRadius: widget.maxRadius,
        ),
        child: Container(), // Empty container to provide size for CustomPaint
      ),
    );
  }
}
