// lib/screens/profile/widgets/profile_info_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({super.key});

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
          'Profile Info Section (Placeholder)',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
      ),
    );
  }
}