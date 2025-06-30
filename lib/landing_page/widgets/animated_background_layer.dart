import 'package:flutter/material.dart';

class AnimatedBackgroundLayer extends StatefulWidget {
  const AnimatedBackgroundLayer({super.key});

  @override
  State<AnimatedBackgroundLayer> createState() => _AnimatedBackgroundLayerState();
}

class _AnimatedBackgroundLayerState extends State<AnimatedBackgroundLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(_animation.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;

  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Draw a gradient with shifting colors based on progress
    final rect = Offset.zero & size;
    paint.shader = LinearGradient(
      colors: [
        Color.lerp(Colors.deepPurple.shade900, Colors.indigo.shade700, progress)!,
        Color.lerp(Colors.blue.shade800, Colors.deepPurple.shade800, progress)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    canvas.drawRect(rect, paint);

    // Optionally add subtle animated circles or shapes here
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
