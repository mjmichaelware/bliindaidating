import 'package:flutter/material.dart';

class GuidedTourScreen extends StatelessWidget {
  const GuidedTourScreen({super.key});

  final List<Map<String, String>> tourSteps = const [
    {
      'title': 'Welcome to Blind AI Dating',
      'description': 'Discover meaningful connections without distractions.',
    },
    {
      'title': 'Personalize Your Profile',
      'description': 'Share your personality, astrology, and interests.',
    },
    {
      'title': 'Attend Events',
      'description': 'Join local events planned just for you.',
    },
    {
      'title': 'Respect Privacy',
      'description': 'No pictures, no swiping. Just real connections.',
    },
    {
      'title': 'Get Matched',
      'description': 'AI matches you based on compatibility and location.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Tour'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: tourSteps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final step = tourSteps[index];
            return Card(
              color: Colors.deepPurple.shade900.withAlpha(220),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step['description']!,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
