// lib/widgets/dashboard_menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile model
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase auth
import 'package:bliindaidating/app_constants.dart'; // For theme colors and fonts

class DashboardMenuDrawer extends StatelessWidget {
  final UserProfile? userProfile;
  final String? avatarUrl;

  const DashboardMenuDrawer({
    super.key,
    this.userProfile,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Determine display name and avatar, handling nulls gracefully
    final String displayName = userProfile?.fullName ?? 'Welcome, User!';
    final ImageProvider? displayAvatar = avatarUrl != null
        ? NetworkImage(avatarUrl!)
        : (userProfile?.profilePictureUrl != null
            ? NetworkImage(userProfile!.profilePictureUrl!)
            : null); // Fallback to profile's own URL if avatarUrl is null

    return Drawer(
      backgroundColor: AppConstants.surfaceColor, // Consistent with theme
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppConstants.secondaryColor,
                  backgroundImage: displayAvatar,
                  child: displayAvatar == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppConstants.textLowEmphasis,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppConstants.textHighEmphasis,
                        fontFamily: 'Inter', // Apply Inter font
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Optionally display email or other quick info
                Text(
                  userProfile?.id ?? 'Guest', // Display user ID as placeholder
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textMediumEmphasis,
                        fontFamily: 'Inter', // Apply Inter font
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppConstants.iconColor),
            title: Text(
              'Home',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/home');
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppConstants.iconColor),
            title: Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/edit_profile'); // Or '/profile_setup' if profile isn't complete
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded, color: AppConstants.iconColor),
            title: Text(
              'My Matches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/matches');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note_rounded, color: AppConstants.iconColor),
            title: Text(
              'Local Events',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/events');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded, color: AppConstants.iconColor),
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/settings');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_rounded, color: AppConstants.iconColor),
            title: Text(
              'About Us',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/about-us');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_rounded, color: AppConstants.iconColor),
            title: Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/privacy');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded, color: AppConstants.iconColor),
            title: Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () {
              context.go('/terms');
              Navigator.pop(context);
            },
          ),
          // Add a logout button
          const Divider(), // Visual separation
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppConstants.errorColor),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.errorColor,
                    fontFamily: 'Inter', // Apply Inter font
                  ),
            ),
            onTap: () async {
              try {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login'); // Redirect to login page
                }
              } catch (e) {
                debugPrint('Error signing out: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}