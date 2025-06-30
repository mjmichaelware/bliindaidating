import 'package:flutter/material.dart';

class MatchIntentionsScreen extends StatefulWidget {
  const MatchIntentionsScreen({super.key});

  @override
  State<MatchIntentionsScreen> createState() => _MatchIntentionsScreenState();
}

class _MatchIntentionsScreenState extends State<MatchIntentionsScreen> {
  final List<String> _intentions = [
    'Long-term Relationship',
    'Casual Dating',
    'Friendship',
    'Networking',
    'Open to See What Happens',
  ];

  final Set<String> _selectedIntentions = {};

  void _toggleIntention(String intention) {
    setState(() {
      if (_selectedIntentions.contains(intention)) {
        _selectedIntentions.remove(intention);
      } else {
        _selectedIntentions.add(intention);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Intentions'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Select your dating intentions. Others will see these when matching with you.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _intentions.map((intention) {
                  final selected = _selectedIntentions.contains(intention);
                  return Card(
                    color: selected ? Colors.deepPurpleAccent : Colors.deepPurple.shade900,
                    child: ListTile(
                      title: Text(
                        intention,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.white54),
                      onTap: () => _toggleIntention(intention),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                // Save intentions logic here
                Navigator.pop(context);
              },
              child: const Text(
                'Save Intentions',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
