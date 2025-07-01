import 'package:flutter/material.dart';
import 'package:bliind_ai_dating/widgets/animated_count.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Animation<double> pulseAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.pulseAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade900.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: pulseAnimation,
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      letterSpacing: 0.9,
                    ),
                  ),
                  AnimatedCount(
                    count: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
