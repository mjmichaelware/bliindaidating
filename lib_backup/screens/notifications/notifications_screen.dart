import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeExtraLarge,
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.cardColor.withOpacity(0.7) : AppConstants.lightCardColor.withOpacity(0.7),
        iconTheme: IconThemeData(color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
        elevation: 0, // No shadow for app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 80,
              color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
            ),
            SizedBox(height: AppConstants.spacingMedium),
            Text(
              'No new notifications.',
              style: TextStyle(
                color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
                fontSize: AppConstants.fontSizeMedium,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingSmall),
            Text(
              'Check back later for updates on matches, events, and more!',
              style: TextStyle(
                color: isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.8) : AppConstants.lightTextLowEmphasis.withOpacity(0.8),
                fontSize: AppConstants.fontSizeSmall,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}