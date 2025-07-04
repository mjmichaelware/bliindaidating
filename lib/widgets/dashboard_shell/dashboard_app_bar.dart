// lib/widgets/dashboard_shell/dashboard_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

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
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          onPressed: () {
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
            debugPrint('Logout button pressed (logic needs to be handled by parent/service)!');
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