import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ADDED: Parameter to show profile completion status (e.g., an indicator)
  final bool showProfileCompletion;

  const DashboardAppBar({
    super.key,
    this.showProfileCompletion = false, // Default to false if not provided
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return AppBar(
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeTitle,
            color: isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // OPTIONAL: Add a visual indicator for profile completion here
        // For example, a small dot or icon next to notifications if showProfileCompletion is true
        if (showProfileCompletion)
          Padding(
            padding: EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Icon(
              Icons.warning_rounded, // Or a custom icon
              color: AppConstants.errorColor, // Highlight incomplete status
              size: AppConstants.fontSizeLarge,
            ),
          ),
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
            // Navigate to notifications screen
            context.push('/notifications');
            debugPrint('Notification button pressed!');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
            context.push('/settings');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () async {
            debugPrint('Logout button pressed! Attempting to sign out.');
            try {
              await Supabase.instance.client.auth.signOut();
              // The GoRouterRefreshStream in main.dart will detect this auth state change
              // and automatically redirect the user to the appropriate page (e.g., /login or /portal_hub).
              // No explicit context.go() call is needed here, as it's handled by the redirect logic.
            } catch (e) {
              debugPrint('Error signing out: $e');
              // Optionally show a user-friendly message if logout fails
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
              );
            }
          },
        ),
        SizedBox(width: AppConstants.paddingSmall),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}