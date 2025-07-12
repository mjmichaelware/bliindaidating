// lib/widgets/glowing_aura.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For AppConstants colors

/// A widget that creates a subtly pulsing glowing aura around its child.
///
/// This uses an [AnimatedBuilder] and a [TweenAnimationBuilder] to create
/// a continuous, soft glow effect, typically around a central element.
class GlowingAura extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlurRadius;
  final double maxSpreadRadius;
  final Duration duration;

  const GlowingAura({
    super.key,
    required this.child,
    this.glowColor = AppConstants.primaryColor, // Default glow color
    this.maxBlurRadius = 30.0,
    this.maxSpreadRadius = 10.0,
    this.duration = const Duration(seconds: 3), // Pulsing duration
  });

  @override
  State<GlowingAura> createState() => _GlowingAuraState();
}

class _GlowingAuraState extends State<GlowingAura> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double currentBlur = widget.maxBlurRadius * _animation.value;
        final double currentSpread = widget.maxSpreadRadius * _animation.value;
        final double currentOpacity = 0.3 + 0.7 * _animation.value; // Pulse opacity

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Assuming the aura is around a circular element
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(currentOpacity),
                blurRadius: currentBlur,
                spreadRadius: currentSpread,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
