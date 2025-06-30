import 'package:flutter/material.dart';

class UserProgressScreen extends StatelessWidget {
  const UserProgressScreen({super.key});

  // Example progress stats
  final Map<String, int> progressStats = const {
    'Profile Completeness': 85,
    'Events Attended': 12,
    'Daily Prompts Completed': 34,
    'Matches Made': 7,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: progressStats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value / 100,
                    color: Colors.deepPurpleAccent,
                    backgroundColor: Colors.white12,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.value}%',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
