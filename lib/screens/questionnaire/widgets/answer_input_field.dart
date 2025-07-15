// lib/screens/questionnaire/widgets/answer_input_field.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class AnswerInputField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isDarkMode; // Pass dark mode status

  const AnswerInputField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    required this.isDarkMode,
  });

  @override
  State<AnswerInputField> createState() => _AnswerInputFieldState();
}

class _AnswerInputFieldState extends State<AnswerInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant AnswerInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if initialValue changes from outside
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      // Ensure cursor is at the end after programmatic text change
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ThemeController is not directly used here as isDarkMode is passed as a prop
    // final theme = Provider.of<ThemeController>(context);
    // final isDarkMode = theme.isDarkMode;

    return TextField(
      controller: _controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        hintStyle: TextStyle(color: widget.isDarkMode ? AppConstants.textMediumEmphasis.withOpacity(0.7) : AppConstants.lightTextMediumEmphasis.withOpacity(0.7)),
        filled: true,
        fillColor: widget.isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.secondaryColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide(color: AppConstants.borderColor.withOpacity(0.5), width: 1.0),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      style: TextStyle(
        color: widget.isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
      ),
    );
  }
}