import 'package:flutter/material.dart';

class MatchIntentionsScreen extends StatefulWidget {
  const MatchIntentionsScreen({super.key});

  @override
  State<MatchIntentionsScreen> createState() => _MatchIntentionsScreenState();
}

class _MatchIntentionsScreenState extends State<MatchIntentionsScreen> {
  final List<String> intentions = [
    'Long-term Relationship',
    'Casual Dating',
    'Friendship',
    'Networking',
    'Open to Explore',
  ];

  late Set<String> selectedIntentions;

  @override
  void initState() {
    super.initState();
    selectedIntentions = {};
  }

  void toggleSelection(String intention) {
    setState(() {
      if (selectedIntentions.contains(intention)) {
        selectedIntentions.remove(intention);
      } else {
        selectedIntentions.add(intention);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Dating Intentions'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you looking for?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: intentions.length,
                itemBuilder: (context, index) {
                  final intention = intentions[index];
                  final selected = selectedIntentions.contains(intention);
                  return Card(
                    color: selected
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        intention,
                        style: TextStyle(
                          color:
                              selected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          : null,
                      onTap: () => toggleSelection(intention),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              onPressed: () {
                // TODO: Save intentions logic here, e.g., call a service or provider
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Intentions saved: ${selectedIntentions.join(', ')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                );
              },
              child: const Text(
                'Save Intentions',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
