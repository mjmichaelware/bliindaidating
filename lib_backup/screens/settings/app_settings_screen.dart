import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _privacyMode = false;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get notified about matches and events'),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Privacy Mode'),
              subtitle: const Text('Hide profile temporarily from discovery'),
              value: _privacyMode,
              onChanged: (val) {
                setState(() {
                  _privacyMode = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for the app'),
              value: _darkMode,
              onChanged: (val) {
                setState(() {
                  _darkMode = val;
                });
                // You can implement theme switching logic here later
              },
            ),
            const Divider(height: 40, color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded, color: Colors.deepPurpleAccent),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Implement navigation or modal for privacy policy
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: Colors.deepPurpleAccent),
              title: const Text('Help & Support'),
              onTap: () {
                // Implement navigation or modal for help & support
              },
            ),
          ],
        ),
      ),
    );
  }
}
