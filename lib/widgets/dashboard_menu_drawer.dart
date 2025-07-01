// lib/widgets/dashboard_menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for logout

class DashboardMenuDrawer extends StatelessWidget {
  const DashboardMenuDrawer({super.key});

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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://placehold.co/60x60/cccccc/000000?text=User'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome, User Name!',
                    style: TextStyle(
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
                // Implement actual logout logic here using Supabase
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
        // Removed Navigator.pop(context) from here to ensure it's handled in onTap callback
        // for consistency with the async logout operation.
        onTap();
      },
    );
  }
}