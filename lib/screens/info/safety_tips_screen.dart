import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  final List<String> safetyTips = const [
    'Always meet in public places.',
    'Tell a friend or family member where you’re going.',
    'Keep your phone charged and with you at all times.',
    'Avoid sharing too much personal information upfront.',
    'Trust your instincts — if something feels off, leave.',
    'Arrange your own transportation to and from dates.',
    'Limit alcohol consumption on first meetings.',
    'Report any suspicious behavior through the app.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: safetyTips.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white24),
          itemBuilder: (context, index) {
            final tip = safetyTips[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                tip,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            );
          },
        ),
      ),
    );
  }
}
