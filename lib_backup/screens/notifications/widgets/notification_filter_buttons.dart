// lib/screens/notifications/widgets/notification_filter_buttons.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NotificationFilterButtons extends StatelessWidget {
  const NotificationFilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
          ),
          child: Text(
            'All',
            style: TextStyle(
              color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
          ),
          child: Text(
            'Unread',
            style: TextStyle(
              color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            ),
          ),
        ),
      ],
    );
  }
}