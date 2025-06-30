import 'package:flutter/material.dart';

class MatchInsightsScreen extends StatelessWidget {
  final String matchName;
  final Map<String, dynamic> insights;

  const MatchInsightsScreen({
    super.key,
    required this.matchName,
    required this.insights,
  });

  Widget _buildInsightTile(String label, String reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade800.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.shade100.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Why You and $matchName?'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: insights.entries.map((e) {
            return _buildInsightTile(e.key, e.value);
          }).toList(),
        ),
      ),
    );
  }
}
