import 'package:flutter/material.dart';

class FavoritesListScreen extends StatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  State<FavoritesListScreen> createState() => _FavoritesListScreenState();
}

class _FavoritesListScreenState extends State<FavoritesListScreen> {
  // For privacy, no pictures, just simple info
  List<Map<String, String>> favorites = [
    {
      'username': 'stargazer42',
      'age': '29',
      'commonInterest': 'Travel',
      'personality': 'Explorer',
    },
    {
      'username': 'booklover',
      'age': '34',
      'commonInterest': 'Reading',
      'personality': 'Introvert',
    },
    {
      'username': 'foodie123',
      'age': '26',
      'commonInterest': 'Cooking',
      'personality': 'Empath',
    },
  ];

  void removeFavorite(int index) {
    setState(() {
      favorites.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          backgroundColor: Colors.deepPurple.shade900,
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'No favorites added yet.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.deepPurple.shade900,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: favorites.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white24),
          itemBuilder: (context, index) {
            final fav = favorites[index];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              tileColor: Colors.deepPurple.shade800.withAlpha(180),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                fav['username'] ?? '',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.pink.shade300),
              ),
              subtitle: Text(
                'Age: ${fav['age']}, Common interest: ${fav['commonInterest']}, Personality: ${fav['personality']}',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                onPressed: () => removeFavorite(index),
                tooltip: 'Remove from favorites',
              ),
            );
          },
        ),
      ),
    );
  }
}
