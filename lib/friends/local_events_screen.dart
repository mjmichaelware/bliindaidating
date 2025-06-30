import 'package:flutter/material.dart';

class LocalEventsScreen extends StatelessWidget {
  const LocalEventsScreen({super.key});

  // Example static event data
  final List<Map<String, dynamic>> _events = const [
    {
      'title': 'Coffee Meetup',
      'location': 'Cafe Aroma',
      'date': 'July 10, 2025',
      'description': 'A casual coffee meetup for singles.'
    },
    {
      'title': 'Art Walk',
      'location': 'Downtown Gallery',
      'date': 'July 15, 2025',
      'description': 'Explore local art and meet new people.'
    },
    {
      'title': 'Live Jazz Night',
      'location': 'Blue Note Club',
      'date': 'July 20, 2025',
      'description': 'Enjoy live jazz and connect.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Near You'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event['location'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event['date'] ?? '',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  event['description'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
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
