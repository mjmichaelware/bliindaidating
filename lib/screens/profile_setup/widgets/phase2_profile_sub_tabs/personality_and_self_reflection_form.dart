    import 'package:flutter/material.dart';
    import 'package:provider/provider.dart';
    import 'package:bliindaidating/app_constants.dart';
    import 'package:bliindaidating/controllers/theme_controller.dart';

    class PersonalityAndSelfReflectionForm extends StatelessWidget {
      const PersonalityAndSelfReflectionForm({super.key});

      @override
      Widget build(BuildContext context) {
        final theme = Provider.of<ThemeController>(context);
        final isDarkMode = theme.isDarkMode;
        final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
        final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Personality & Self-Reflection Form (Under Construction)',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'This form will delve into your personality traits and self-perception.',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeBody,
                  color: textMediumEmphasis,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }
    