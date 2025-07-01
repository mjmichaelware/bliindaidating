// lib/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController
import 'package:bliindaidating/app_constants.dart'; // For AppConstants colors

/// A toggle button for switching between light and dark themes with a cosmic animation.
///
/// This widget displays a sun or moon icon that morphs and rotates
/// when the theme is toggled, providing a visually engaging transition.
class ThemeToggle extends StatefulWidget {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationLong, // 1 second for the animation
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Control animation direction based on theme change
    if (isDarkMode && _controller.status != AnimationStatus.forward) {
      _controller.reverse(); // Animate to moon (dark mode)
    } else if (!isDarkMode && _controller.status != AnimationStatus.reverse) {
      _controller.forward(); // Animate to sun (light mode)
    }

    return GestureDetector(
      onTap: () {
        themeController.toggleTheme();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * (isDarkMode ? -math.pi : math.pi), // Rotate based on theme
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                isDarkMode ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                size: AppConstants.fontSizeLarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
