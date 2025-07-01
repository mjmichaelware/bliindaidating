// lib/widgets/dashboard_menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for logout
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile model

class DashboardMenuDrawer extends StatelessWidget {
  // Added optional userProfile and avatarUrl parameters
  final UserProfile? userProfile;
  final String? avatarUrl;

  const DashboardMenuDrawer({
    super.key,
    this.userProfile, // Accepted userProfile
    this.avatarUrl,   // Accepted avatarUrl
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade800,
              ),
              child: Column( // Removed const here because of dynamic content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    // Display user's avatar if available, else a placeholder
                    backgroundImage: (avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage('assets/images/default_avatar.png')) as ImageProvider, // Assuming a default_avatar.png exists or use a generic icon
                    backgroundColor: Colors.grey, // Fallback background
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProfile?.display_name ?? 'Welcome, User!', // Display user's name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard_rounded,
              text: 'Main Dashboard',
              onTap: () => context.go('/home'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.person_rounded,
              text: 'Edit Profile',
              onTap: () => context.go('/profile_setup'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.search_rounded,
              text: 'Discover Profiles',
              onTap: () => context.go('/discovery'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.favorite_rounded,
              text: 'Your Matches',
              onTap: () => context.go('/matches'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              text: 'Settings',
              onTap: () => context.go('/settings'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.feedback_rounded,
              text: 'Submit Feedback',
              onTap: () => context.go('/feedback'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.flag_rounded,
              text: 'Report User',
              onTap: () => context.go('/report'),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.admin_panel_settings_rounded,
              text: 'Admin Panel',
              onTap: () => context.go('/admin'),
              context: context,
            ),
            const Divider(color: Colors.white54),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              text: 'Logout',
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                  debugPrint('User successfully logged out.');
                  if (context.mounted) {
                    Navigator.pop(context); // Close the drawer
                    context.go('/login'); // Navigate to login page
                  }
                } catch (e) {
                  debugPrint('Error during logout: $e');
                  // Optionally show an error message to the user
                }
              },
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        onTap();
      },
    );
  }
}