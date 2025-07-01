// lib/widgets/animated_tagline.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For AppConstants.textColor and font

/// A widget that displays an animated tagline with a fade and subtle glow effect.
///
/// This widget uses a [TweenAnimationBuilder] to create a continuous
/// fade and glow animation for the tagline text, enhancing the cosmic theme.
class AnimatedTagline extends StatelessWidget {
  final String text;
  final TextStyle style;
  final ColorTween glowColorTween;
  final double blurRadius;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedTagline({
    super.key,
    required this.text,
    this.style = const TextStyle(
      fontFamily: 'Inter',
      fontSize: AppConstants.fontSizeLarge,
      fontWeight: FontWeight.w600,
      color: AppConstants.textColor,
      letterSpacing: 1.0,
    ),
    this.glowColorTween = const ColorTween(
      begin: AppConstants.primaryColor,
      end: AppConstants.secondaryColor,
    ),
    this.blurRadius = 10.0,
    this.animationDuration = const Duration(seconds: 3),
    this.animationCurve = Curves.easeInOutSine,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, value, child) {
        final Color currentGlowColor = glowColorTween.evaluate(AlwaysStoppedAnimation(value))!;
        final double currentBlur = blurRadius * value;
        return Opacity(
          opacity: 0.5 + 0.5 * value, // Fade in/out effect
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: style.copyWith(
              shadows: [
                BoxShadow(
                  color: currentGlowColor.withOpacity(0.5 + 0.5 * value),
                  blurRadius: currentBlur,
                  offset: const Offset(0, 0), // Centered shadow for glow
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        // This makes the animation repeat
        (context as Element).markNeedsBuild();
      },
    );
  }
}
