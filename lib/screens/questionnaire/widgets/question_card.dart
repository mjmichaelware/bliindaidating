// lib/screens/questionnaire/widgets/question_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      margin: EdgeInsets.symmetric(vertical: AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Center(
        child: Text(
          'Question Card (Placeholder)',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
      ),
    );
  }
}