    import 'package:flutter/material.dart';
    import 'package:provider/provider.dart';
    import 'package:bliindaidating/app_constants.dart';
    import 'package:bliindaidating/controllers/theme_controller.dart';

    class PersonalAndContactForm extends StatelessWidget {
      const PersonalAndContactForm({super.key});

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
                'Personal & Contact Form (Under Construction)',
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
                'This form will collect basic personal details and contact information.',
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
    