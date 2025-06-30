import 'package:flutter/material.dart';

class CompatibilityScoreWidget extends StatelessWidget {
  final double score; // 0.0 to 100.0
  final String personalityMatch;
  final List<String> sharedValues;
  final String summary;

  const CompatibilityScoreWidget({
    super.key,
    required this.score,
    required this.personalityMatch,
    required this.sharedValues,
    required this.summary,
  });

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.greenAccent.shade400;
    if (score >= 60) return Colors.amberAccent.shade400;
    return Colors.redAccent.shade200;
  }

  String _getScoreLabel(double score) {
    if (score >= 85) return 'Highly Compatible';
    if (score >= 60) return 'Moderately Compatible';
    return 'Low Compatibility';
  }

  IconData _getScoreIcon(double score) {
    if (score >= 85) return Icons.stars_rounded;
    if (score >= 60) return Icons.favorite_border;
    return Icons.warning_amber_rounded;
  }

  Widget _buildSharedValueChips(List<String> values) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: values
          .map((value) => Chip(
                label: Text(value),
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: Colors.deepPurple.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(score);
    final scoreLabel = _getScoreLabel(score);
    final scoreIcon = _getScoreIcon(score);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.6),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(scoreIcon, color: scoreColor, size: 36),
              const SizedBox(width: 12),
              Text(
                'Compatibility Score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${score.toInt()}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scoreLabel,
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Personality Match',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            personalityMatch,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Shared Values',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          _buildSharedValueChips(sharedValues),
          const SizedBox(height: 18),
          Text(
            'Why You Might Work',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
