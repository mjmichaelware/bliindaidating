// lib/shared/glowing_button.dart

import 'package:flutter/material.dart';

class GlowingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Color color;
  final Gradient? gradient;
  // Ensure this parameter is present and correctly typed
  final List<Color>? gradientColors;
  final double? width;
  final double? height;
  final double glowSpreadRadius;
  final double glowBlurRadius;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;

  const GlowingButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.color = Colors.blue,
    this.gradient,
    // Add gradientColors to the constructor parameters list
    this.gradientColors,
    this.width,
    this.height,
    this.glowSpreadRadius = 4,
    this.glowBlurRadius = 15,
    this.borderRadius = 25.0,
    this.boxShadow,
    this.textStyle,
  }) : assert(
          child != null || text != null || icon != null,
          'GlowingButton must have either a child, text, or an icon.',
        );

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (child != null) {
      content = child!;
    } else if (text != null && icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textStyle?.color ?? Colors.white, size: (textStyle?.fontSize ?? 16) * 1.2),
          const SizedBox(width: 8),
          Text(text!, style: textStyle ?? const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      );
    } else if (text != null) {
      content = Text(text!, style: textStyle ?? const TextStyle(color: Colors.white, fontSize: 16));
    } else if (icon != null) {
      content = Icon(icon, color: textStyle?.color ?? Colors.white, size: (textStyle?.fontSize ?? 16) * 1.5);
    } else {
      content = const SizedBox.shrink();
    }

    // Determine the gradient to use
    Gradient? effectiveGradient;
    if (gradientColors != null && gradientColors!.isNotEmpty) {
      effectiveGradient = LinearGradient(
        colors: gradientColors!,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      effectiveGradient = gradient ??
          LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: glowBlurRadius,
                  spreadRadius: glowSpreadRadius,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
