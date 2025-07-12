import 'package:flutter/material.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  final List<String> activityItems = const [
    'You updated your profile today.',
    'You liked a new personality type match.',
    'New event near you: “Coffee & Conversations”.',
    'You completed a daily prompt.',
    'Your profile was viewed 5 times this week.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activityItems.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.timeline_rounded, color: Colors.deepPurpleAccent),
            title: Text(
              activityItems[index],
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
