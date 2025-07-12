// lib/screens/profile_setup/tabs/phase2_questionnaire_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_data_tab.dart'; // Import the main data tab

class Phase2QuestionnaireTab extends StatelessWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate; // Callback to update parent state

  const Phase2QuestionnaireTab({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final bool isDarkMode = themeController.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
            isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Phase2ProfileDataTab(
        userProfile: userProfile,
        onUpdate: onUpdate,
      ),
    );
  }
}