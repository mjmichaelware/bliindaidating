// lib/screens/questionnaire/widgets/answer_input_field.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class AnswerInputField extends StatelessWidget {
  const AnswerInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        fillColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
      ),
    );
  }
}