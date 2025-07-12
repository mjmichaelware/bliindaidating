import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';

class AdventureGateButtons extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onCreate;

  const AdventureGateButtons({
    super.key,
    required this.onExplore,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size?.width < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: GlowingButton(
            text: 'Explore Realms',
            icon: Icons.explore_rounded,
            onPressed: onExplore,
            gradientColors: [
              Colors.deepPurple.shade600,
              Colors.indigo.shade400,
            ],
            height: isSmallScreen ? 44 : 56,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
