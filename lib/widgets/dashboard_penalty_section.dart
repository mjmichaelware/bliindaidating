import 'package:flutter/material.dart';
import 'package:bliind_ai_dating/widgets/animated_penalty_cross.dart';

class DashboardPenaltySection extends StatelessWidget {
  final int penaltyCount;

  const DashboardPenaltySection({super.key, required this.penaltyCount});

  @override
  Widget build(BuildContext context) {
    if (penaltyCount <= 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade900.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded, size: 40, color: Colors.white),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'You have no penalties! Keep up the great cosmic harmony.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    final displayCount = penaltyCount.clamp(1, 10);

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade700.withOpacity(0.75),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Penalty Alert: You have $penaltyCount date turn-down${penaltyCount > 1 ? 's' : ''}!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            children: List.generate(displayCount, (index) {
              final delay = index * 150;
              return AnimatedPenaltyCross(delay: delay);
            }),
          ),
        ],
      ),
    );
  }
}
