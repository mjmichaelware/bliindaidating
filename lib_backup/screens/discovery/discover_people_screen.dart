import 'package:flutter/material.dart';

class DiscoverPeopleScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const DiscoverPeopleScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: users.length,
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Type: ${user['personality']} | Sign: ${user['zodiac']}',
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${user['hopesAndDreams']}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

