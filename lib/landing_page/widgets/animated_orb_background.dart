import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedOrbBackground extends StatefulWidget {
  const AnimatedOrbBackground({super.key});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Orb> _orbs = [];

  final int orbCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    // Initialize orbs with random positions, sizes, colors
    final random = Random();
    for (int i = 0; i < orbCount; i++) {
      _orbs.add(
        _Orb(
          position: Offset(random.nextDouble(), random.nextDouble()),
          size: 30 + random.nextDouble() * 70,
          color: Colors.purpleAccent.withOpacity(0.2 + random.nextDouble() * 0.3),
          speed: 0.01 + random.nextDouble() * 0.03,
          direction: random.nextBool() ? 1 : -1,
          phaseShift: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: _OrbPainter(_orbs, _controller.value, size),
        );
      },
    );
  }
}

class _Orb {
  Offset position;
  double size;
  Color color;
  double speed;
  int direction;
  double phaseShift;

  _Orb({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.direction,
    required this.phaseShift,
  });
}

class _OrbPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double animationValue;
  final Size canvasSize;

  _OrbPainter(this.orbs, this.animationValue, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var orb in orbs) {
      final dx = (orb.position.dx + orb.direction * orb.speed * animationValue) % 1.0;
      final dy = (orb.position.dy + orb.direction * orb.speed * animationValue) % 1.0;

      final orbPosition = Offset(dx * canvasSize.width, dy * canvasSize.height);

      final gradient = RadialGradient(
        colors: [
          orb.color.withOpacity(0.0),
          orb.color.withOpacity(0.2),
          orb.color.withOpacity(0.6),
          orb.color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4, 0.6, 1.0],
      );

      final rect = Rect.fromCircle(center: orbPosition, radius: orb.size);

      paint.shader = gradient.createShader(rect);
      canvas.drawCircle(orbPosition, orb.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
