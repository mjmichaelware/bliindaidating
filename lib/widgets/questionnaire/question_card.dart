// lib/widgets/questionnaire/question_card.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final bool isDarkMode;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              question,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // You can add an image or icon here related to the question
            Icon(
              Icons.help_outline_rounded,
              size: AppConstants.iconSizeLarge,
              color: textColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}