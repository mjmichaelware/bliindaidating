import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final List<String> blockedUsers = [
    'User123',
    'Spammer456',
    'AnnoyingGuy789',
  ];

  void _unblockUser(String username) {
    setState(() {
      blockedUsers.remove(username);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unblocked $username')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: (blockedUsers ?? []).isEmpty
          ? Center(
              child: Text(
                'You have not blocked any users.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            )
          : ListView.separated(
              itemCount: blockedUsers.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24),
              itemBuilder: (context, index) {
                final username = blockedUsers[index];
                return ListTile(
                  title: Text(
                    username,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  trailing: TextButton(
                    onPressed: () => _unblockUser(username),
                    child: const Text(
                      'Unblock',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

