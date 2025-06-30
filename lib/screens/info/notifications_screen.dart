import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, String>> notifications = const [
    {
      'title': 'Match Request Accepted',
      'subtitle': 'Your match request with Alex was accepted!',
      'time': '2h ago',
    },
    {
      'title': 'New Event Nearby',
      'subtitle': 'A speed dating event is happening near you this weekend.',
      'time': '1d ago',
    },
    {
      'title': 'Profile Verified',
      'subtitle': 'Your profile verification was successful.',
      'time': '3d ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_rounded, color: Colors.deepPurpleAccent),
                  title: Text(
                    notification['title']!,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    notification['subtitle']!,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  trailing: Text(
                    notification['time']!,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
                  ),
                );
              },
            ),
    );
  }
}
