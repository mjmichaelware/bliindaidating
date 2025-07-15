// lib/screens/quiz/personality_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class PersonalityQuizScreen extends StatelessWidget {
  const PersonalityQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personality Quiz',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade400,
        iconTheme: IconThemeData(color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
      ),
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_satisfied_alt_rounded,
                size: 80,
                color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'This is the Personality Quiz Screen (Placeholder)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  fontSize: AppConstants.fontSizeLarge,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Take a quiz to discover more about your personality and matching traits.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                  fontSize: AppConstants.fontSizeBody,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}