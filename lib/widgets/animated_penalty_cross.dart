import 'package:flutter/material.dart';

class AnimatedPenaltyCross extends StatefulWidget {
  final int delay;

  const AnimatedPenaltyCross({super.key, this.delay = 0});

  @override
  State<AnimatedPenaltyCross> createState() => _AnimatedPenaltyCrossState();
}

class _AnimatedPenaltyCrossState extends State<AnimatedPenaltyCross> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.close_rounded, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
