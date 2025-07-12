// lib/widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final Color glowColor; // Ensure this is present
  final Offset shadowOffset; // Ensure this is present

  const DashboardHeader({
    super.key,
    required this.title,
    this.glowColor = Colors.white, // Default value if not provided
    this.shadowOffset = const Offset(0, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.3), // Uses glowColor
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: shadowOffset, // Uses shadowOffset
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(-shadowOffset?.dx, -shadowOffset?.dy),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: glowColor.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.menu_rounded, size: 30, color: Colors.white.withOpacity(0.8)),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        );
      }
    );
  }
}