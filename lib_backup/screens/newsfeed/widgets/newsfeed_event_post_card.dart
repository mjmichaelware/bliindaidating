// lib/screens/newsfeed/widgets/newsfeed_event_post_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NewsfeedEventPostCard extends StatelessWidget {
  const NewsfeedEventPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      margin: EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Center(
        child: Text(
          'Event Post Card (Placeholder)',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
      ),
    );
  }
}