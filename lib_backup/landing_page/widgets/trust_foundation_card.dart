import 'package:flutter/material.dart';

class TrustFoundationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const TrustFoundationCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size?.width < 600;

    return Semantics(
      container: true,
      label: 'Trust Foundation card: $title',
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 20 : 28,
          horizontal: isSmallScreen ? 20 : 32,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 24,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 3,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 40 : 54,
              color: theme.colorScheme.primary,
              semanticLabel: '$title icon',
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      fontSize: isSmallScreen ? 20 : 26,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isSmallScreen ? 15 : 18,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
