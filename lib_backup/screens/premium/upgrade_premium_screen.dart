import 'package:flutter/material.dart';

class UpgradeToPremiumScreen extends StatelessWidget {
  const UpgradeToPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Premium Features',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.visibility, color: Colors.amber),
              title: Text('See who liked you'),
              subtitle: Text('Know who favorited your profile.'),
            ),
            const ListTile(
              leading: Icon(Icons.flash_on, color: Colors.orangeAccent),
              title: Text('Boosted Profile Visibility'),
              subtitle: Text('Show up more in compatibility matches.'),
            ),
            const ListTile(
              leading: Icon(Icons.lock_open, color: Colors.greenAccent),
              title: Text('Unlock advanced filters'),
              subtitle: Text('Filter by personality type, beliefs, and more.'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement upgrade flow
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Go Premium', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
