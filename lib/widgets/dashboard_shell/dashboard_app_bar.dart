// lib/widgets/dashboard_shell/dashboard_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/auth_service.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showProfileCompletion;
  final VoidCallback? onMenuPressed;

  const DashboardAppBar({
    super.key,
    this.showProfileCompletion = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color appBarBackgroundColor = isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
    final Color appBarPrimaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color appBarSecondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color appBarTextColor = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color appBarIconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;
    final Color errorColor = AppConstants.errorColor;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appBarBackgroundColor.withOpacity(0.8),
              appBarBackgroundColor.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      leading: onMenuPressed != null
          ? Builder( // ADDED Builder here for a more robust context
              builder: (BuildContext innerContext) { // Use innerContext for the Scaffold.of call
                return IconButton(
                  icon: Icon(Icons.menu_rounded, color: appBarIconColor, size: AppConstants.fontSizeExtraLarge),
                  // Changed to call onMenuPressed directly, as it already contains the Scaffold.of(context).openEndDrawer()
                  onPressed: onMenuPressed,
                  tooltip: 'Open menu',
                );
              }
            )
          : null,
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: AppConstants.fontSizeTitle,
          color: appBarTextColor,
          shadows: [
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
      centerTitle: true,
      actions: [
        if (showProfileCompletion)
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Tooltip(
              message: 'Profile Phase 2 Incomplete! Tap to complete.',
              child: IconButton(
                icon: Icon(
                  Icons.warning_rounded,
                  color: errorColor,
                  size: AppConstants.fontSizeExtraLarge,
                ),
                onPressed: () {
                  context.go('/questionnaire-phase2');
                },
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: appBarIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
            context.push('/notifications');
          },
          tooltip: 'Notifications',
        ),
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
        IconButton(
          icon: Icon(
            Icons.logout,
            color: appBarIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () async {
            try {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
            } catch (e) {
              // Handle error, e.g., show SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
              );
            }
          },
          tooltip: 'Logout',
        ),
        const SizedBox(width: AppConstants.paddingSmall),
      ],
      automaticallyImplyLeading: false,
    );
  }
}