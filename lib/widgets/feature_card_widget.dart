// lib/widgets/feature_card_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeatureCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final double iconSize;
  final TextStyle? textStyle;

  const FeatureCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.iconSize = 48.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth < 600
            ? constraints.maxWidth
            : (constraints.maxWidth / 2.2);
        return Container(
          width: cardWidth,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15.0,
                spreadRadius: 5.0,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: color,
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: textStyle ??
                    GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
