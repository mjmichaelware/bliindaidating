// lib/widgets/dashboard_shell/dashboard_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/auth_service.dart'; // FIX: Added missing import for AuthService

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showProfileCompletion;
  final VoidCallback? onMenuPressed; // Optional callback for mobile drawer

  const DashboardAppBar({
    super.key,
    this.showProfileCompletion = false,
    this.onMenuPressed, // Ensure this is passed in
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Use colors from AppConstants based on theme
    final Color appBarBackgroundColor = isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
    final Color appBarPrimaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color appBarSecondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color appBarTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color appBarIconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;
    final Color errorColor = AppConstants.errorColor; // For warning icon

    return AppBar(
      backgroundColor: Colors.transparent, // Make AppBar background transparent to show flexibleSpace
      elevation: 0, // Remove default elevation
      // flexibleSpace allows for custom background drawing behind the AppBar content
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appBarBackgroundColor.withOpacity(0.8), // Start with a slightly opaque background
              appBarBackgroundColor.withOpacity(0.6), // Fade to more transparent
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Subtle shadow for depth
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      // Leading icon for mobile drawer toggle
      leading: onMenuPressed != null
          ? IconButton(
              icon: Icon(Icons.menu_rounded, color: appBarIconColor, size: AppConstants.fontSizeExtraLarge),
              onPressed: onMenuPressed,
              tooltip: 'Open menu',
            )
          : null, // No leading icon if onMenuPressed is null (e.g., for desktop)
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: AppConstants.fontSizeTitle, // Using AppConstants for consistent size
          color: appBarTextColor, // Use textHighEmphasis for main title
          shadows: [
            // Adding a subtle glow effect to the title text
            BoxShadow(
              color: appBarPrimaryColor.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: appBarSecondaryColor.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
      centerTitle: true, // Center the title
      actions: [
        // Profile Completion Warning Indicator
        if (showProfileCompletion)
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Tooltip(
              message: 'Profile Phase 2 Incomplete! Tap to complete.',
              child: IconButton( // Changed to IconButton to make it tappable
                icon: Icon(
                  Icons.warning_rounded,
                  color: errorColor, // Highlight incomplete status with error color
                  size: AppConstants.fontSizeExtraLarge,
                ),
                onPressed: () {
                  // Navigate to Phase 2 setup screen
                  context.go('/questionnaire-phase2');
                },
              ),
            ),
          ),
        // Notifications Button
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: appBarIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
            context.push('/notifications');
            debugPrint('Notification button pressed!');
          },
          tooltip: 'Notifications',
        ),
        // Settings Button
        IconButton(
          icon: Icon(
            Icons.settings,
            color: appBarIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
            context.push('/settings');
          },
          tooltip: 'Settings',
        ),
        // Logout Button
        IconButton(
          icon: Icon(
            Icons.logout,
            color: appBarIconColor, // Keep icon color consistent
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () async {
            debugPrint('Logout button pressed! Attempting to sign out.');
            try {
              // Access AuthService via Provider to sign out
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              // The GoRouterRefreshStream in main.dart will detect this auth state change
              // and automatically redirect the user to the appropriate page.
            } catch (e) {
              debugPrint('Error signing out: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
              );
            }
          },
          tooltip: 'Logout',
        ),
        const SizedBox(width: AppConstants.paddingSmall),
      ],
      automaticallyImplyLeading: false, // Ensure no default back button
    );
  }
}
