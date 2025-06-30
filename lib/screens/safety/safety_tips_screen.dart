import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  final List<String> _tips = const [
    'Meet in public places for the first few dates.',
    'Let a friend or family member know your plans.',
    'Keep your personal information private until you trust someone.',
    'Trust your instincts — if something feels off, it probably is.',
    'Use the app’s reporting features if you feel unsafe.',
    'Arrange your own transportation to and from dates.',
    'Avoid sharing financial information.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Tips')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.separated(
          itemCount: _tips.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.deepPurple),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade700,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(
                _tips[index],
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          },
        ),
      ),
    );
  }
}
