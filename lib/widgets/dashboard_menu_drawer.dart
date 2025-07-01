import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bliind_ai_dating/core/app_router.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://placehold.co/60x60/cccccc/000000?text=User'),
                  ),
                  const SizedBox(height: 10),
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
              onTap: () => context.go(AppRouter.dashboardRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.person_rounded,
              text: 'Edit Profile',
              onTap: () => context.go(AppRouter.profileCreationRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.search_rounded,
              text: 'Discover Profiles',
              onTap: () => context.go(AppRouter.discoveryRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.favorite_rounded,
              text: 'Your Matches',
              onTap: () => context.go(AppRouter.matchesRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              text: 'Settings',
              onTap: () => context.go(AppRouter.settingsRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.feedback_rounded,
              text: 'Submit Feedback',
              onTap: () => context.go(AppRouter.feedbackRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.flag_rounded,
              text: 'Report User',
              onTap: () => context.go(AppRouter.reportRoute),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.admin_panel_settings_rounded,
              text: 'Admin Panel',
              onTap: () => context.go(AppRouter.adminRoute),
              context: context,
            ),
            const Divider(color: Colors.white54),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              text: 'Logout',
              onTap: () {
                // Implement actual logout logic here
                context.go(AppRouter.loginRoute);
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
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
