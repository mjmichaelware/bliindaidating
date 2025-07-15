// lib/widgets/questionnaire/question_progress_indicator.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';

class QuestionProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Color progressColor;
  final Color backgroundColor;

  const QuestionProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalQuestions > 0 ? currentQuestion / totalQuestions : 0.0;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: AppConstants.spacingSmall,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Text(
          'Question $currentQuestion of $totalQuestions',
          style: TextStyle(
            color: AppConstants.textColor.withOpacity(0.8),
            fontSize: AppConstants.fontSizeSmall,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}