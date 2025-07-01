import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart'; // Corrected import path

class DashboardInfoCard extends StatelessWidget {
  final String title;
  final String? description; // Made nullable
  final IconData icon;
  final Color iconColor;
  final Widget? trailingWidget; // Made nullable
  final Widget? customContent; // Added parameter

  const DashboardInfoCard({
    super.key,
    required this.title,
    this.description, // Can be null now
    required this.icon,
    required this.iconColor,
    this.trailingWidget,
    this.customContent, // Added to constructor
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
            color: iconColor.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (description != null) ...[ // Only show if description is not null
            const SizedBox(height: 16),
            Text(
              description!,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
          if (customContent != null) ...[ // Show custom content if provided
            const SizedBox(height: 16), // Add space if description is null
            customContent!,
          ],
          if (trailingWidget != null) ...[ // Show trailing widget if provided
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: trailingWidget!,
            ),
          ],
        ],
      ),
    );
  }
}