import 'package:flutter/material.dart';

class DateIdeasScreen extends StatelessWidget {
  const DateIdeasScreen({super.key});

  final List<String> _dateIdeas = const [
    'Picnic at the park',
    'Visit a local art gallery',
    'Coffee and board games',
    'Sunset walk on the beach',
    'Attend a cooking class',
    'Explore a new hiking trail',
    'Visit a farmer’s market',
    'Go to a live music show',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Ideas of the Week'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _dateIdeas.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          return Card(
            color: Colors.deepPurple.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
              title: Text(
                _dateIdeas[index],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share, color: Colors.deepPurpleAccent),
                onPressed: () {
                  // Share date idea logic can go here
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
