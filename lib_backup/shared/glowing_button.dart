// lib/shared/glowing_button.dart
import 'package:flutter/material.dart';

class GlowingButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed; // Made nullable
  final List<Color> gradientColors;
  final double height;
  final double width;
  final TextStyle textStyle;
  final bool disabled; // Added this parameter

  const GlowingButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed, // No longer required, can be null
    required this.gradientColors,
    this?.height = 50.0,
    this?.width = 200.0,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    this.disabled = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: disabled // Change colors if disabled
              ? [Colors.grey.shade700, Colors.grey.shade500]
              : gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: disabled
            ? [] // No shadow if disabled
            : [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed, // IMPORTANT: Set onPressed to null if disabled
          borderRadius: BorderRadius.circular(height / 2),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: disabled ? Colors.white54 : Colors.white, size: textStyle.fontSize! * 1.2),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: textStyle.copyWith(
                    color: disabled ? Colors.white54 : textStyle.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
