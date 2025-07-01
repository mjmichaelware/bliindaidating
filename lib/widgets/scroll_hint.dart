// lib/widgets/scroll_hint.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bliindaidating/app_constants.dart'; // For AppConstants.textColor

/// A subtle animated scroll hint (pulsing down arrow) to indicate scrollability.
///
/// This widget uses an animation controller to make the arrow pulse and
/// slightly move downwards, encouraging the user to scroll.
class ScrollHint extends StatefulWidget {
  const ScrollHint({super.key});

  @override
  State<ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<ScrollHint> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration for one pulse
    )..repeat(reverse: true); // Repeat with reverse for a pulsing effect

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2), // Move down by 20% of its height
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: FadeTransition(
        opacity: _controller.drive(Tween<double>(begin: 0.5, end: 1.0)), // Pulse opacity
        child: FaIcon(
          FontAwesomeIcons.chevronDown, // Down arrow icon
          color: AppConstants.textColor.withOpacity(0.6), // Subtle color
          size: AppConstants.fontSizeExtraLarge, // Appropriate size
        ),
      ),
    );
  }
}
