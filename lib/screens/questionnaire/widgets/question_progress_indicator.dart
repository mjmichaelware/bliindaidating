// lib/screens/questionnaire/widgets/question_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class QuestionProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const QuestionProgressIndicator({super.key, this.progress = 0.5});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
      valueColor: AlwaysStoppedAnimation<Color>(
        isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
      ),
    );
  }
}