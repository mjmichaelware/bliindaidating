// lib/widgets/questionnaire/answer_input_field.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';

class AnswerInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onAiSuggest; // New callback for AI suggestion
  final bool isDarkMode;

  const AnswerInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onAiSuggest, // Made optional
    required this.isDarkMode,
  });

  @override
  State<AnswerInputField> createState() => _AnswerInputFieldState();
}

class _AnswerInputFieldState extends State<AnswerInputField> {
  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color hintColor = widget.isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = widget.isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = widget.isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);
    final Color activeColor = widget.isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    return Column(
      children: [
        TextField(
          controller: widget.controller,
          maxLines: 3,
          minLines: 1,
          style: TextStyle(color: textColor, fontFamily: 'Inter', fontSize: AppConstants.fontSizeMedium),
          decoration: InputDecoration(
            labelText: 'Your Answer',
            labelStyle: TextStyle(color: hintColor, fontFamily: 'Inter', fontSize: AppConstants.fontSizeMedium),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: activeColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
          ),
          cursorColor: activeColor,
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.onAiSuggest != null)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
              child: TextButton.icon(
                onPressed: widget.onAiSuggest,
                icon: Icon(Icons.auto_awesome, color: activeColor, size: AppConstants.fontSizeLarge),
                label: Text(
                  'AI Suggest',
                  style: TextStyle(
                    color: activeColor,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Remove default padding
                  minimumSize: Size.zero, // Remove minimum size constraints
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                ),
              ),
            ),
          ),
      ],
    );
  }
}