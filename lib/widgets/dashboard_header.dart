import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onMenuPressed;

  const DashboardHeader({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Main Dashboard',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                shadows: const [
                  Shadow(
                    color: Colors.redAccent,
                    blurRadius: 18,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 36, color: Colors.white),
              onPressed: onMenuPressed,
            ),
          ],
        ),
      ),
    );
  }
}
