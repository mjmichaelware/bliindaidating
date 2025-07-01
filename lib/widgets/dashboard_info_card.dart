import 'package:flutter/material.dart';
import 'package:bliind_ai_dating/shared/glowing_button.dart';

class DashboardInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Widget? trailingWidget;
  final List<Widget>? children;

  const DashboardInfoCard({
    super.key,
    required this.title,
    this.description = '',
    required this.icon,
    required this.iconColor,
    this.trailingWidget,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.6),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 44, color: iconColor),
                  const SizedBox(width: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (trailingWidget != null) trailingWidget!,
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
          if (children != null) ...[
            const SizedBox(height: 16),
            ...children!,
          ],
        ],
      ),
    );
  }
}
