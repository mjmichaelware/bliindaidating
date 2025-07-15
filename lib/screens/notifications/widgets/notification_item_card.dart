// lib/screens/notifications/widgets/notification_item_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NotificationItemCard extends StatelessWidget {
  final String notificationText; // Changed to take a specific notification text
  // You might later change this to final NotificationItem notification;
  // if you define a NotificationItem model with more structured data.

  const NotificationItemCard({
    super.key,
    required this.notificationText, // Require notification text
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined, // You can make this dynamic based on notification type
            color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
            size: AppConstants.fontSizeExtraLarge,
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Update', // You might make this dynamic (e.g., "New Match!", "Event Reminder")
                  style: TextStyle(
                    color: isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis,
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                Text(
                  notificationText, // Display the actual notification content
                  style: TextStyle(
                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    fontSize: AppConstants.fontSizeBody,
                  ),
                ),
                // You could add a timestamp here if your notification model includes it
                // Text(
                //   '${timeago.format(notification.timestamp)}', // Requires timeago package
                //   style: TextStyle(
                //     color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
                //     fontSize: AppConstants.fontSizeSmall,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}