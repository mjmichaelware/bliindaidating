import 'package:flutter/material.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of matches, replace with actual data
    final matches = ['Alice', 'Bob', 'Charlie'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final matchName = matches[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(matchName),
              subtitle: const Text('You have a mutual interest!'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle view profile action
                },
                child: Text('View Profile'), // ← FIXED: removed `const`
              ),
            ),
          );
        },
      ),
    );
  }
}
