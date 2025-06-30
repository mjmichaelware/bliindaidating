import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<String> notifications = const [
    'Your profile was featured today.',
    'New event near you: “Sunset Yoga”.',
    'You have 3 new suggested matches.',
    'Reminder: Update your availability.',
    'Your subscription will renew soon.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications_rounded, color: Colors.deepPurpleAccent),
            title: Text(
              notifications[index],
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
