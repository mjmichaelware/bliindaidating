import 'package:flutter/material.dart';

class MatchIntentionsScreen extends StatefulWidget {
  final List<String> currentIntentions;

  const MatchIntentionsScreen({
    super.key,
    required this.currentIntentions,
  });

  @override
  State<MatchIntentionsScreen> createState() => _MatchIntentionsScreenState();
}

class _MatchIntentionsScreenState extends State<MatchIntentionsScreen> {
  final List<String> _allIntentions = const [
    'Long‑term Relationship',
    'Short‑term Dating',
    'Open to Explore',
    'Friendship',
    'Activity Partner',
  ];

  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.currentIntentions);
  }

  void _onChipTapped(String intention) {
    setState(() {
      if (_selected.contains(intention)) {
        _selected.remove(intention);
      } else {
        _selected.add(intention);
      }
    });
  }

  void _saveAndPop() {
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Dating Intentions'),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you hoping to find here?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (_allIntentions ?? []).map((intention) {
                final bool selected = _selected.contains(intention);
                return FilterChip(
                  label: Text(intention),
                  selected: selected,
                  onSelected: (_) => _onChipTapped(intention),
                  selectedColor: Colors.pink.shade400,
                  backgroundColor: Colors.deepPurple.shade700,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndPop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
