// lib/screens/profile/widgets/profile_edit_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class ProfileEditButton extends StatelessWidget {
  const ProfileEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return ElevatedButton(
      onPressed: () {
        // Implement edit profile navigation/logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
      child: Text(
        'Edit Profile',
        style: TextStyle(
          color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
        ),
      ),
    );
  }
}