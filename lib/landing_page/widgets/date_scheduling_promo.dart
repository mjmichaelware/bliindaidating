import 'package:flutter/material.dart';

class DateSchedulingPromo extends StatelessWidget {
  const DateSchedulingPromo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Effortless Date Scheduling',
            style: TextStyle(
              fontSize: isSmallScreen ? 26 : 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Coordinate your meetings with cosmic precision and harmony. Let the stars guide your plans seamlessly.',
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 17,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
