// lib/widgets/help_dialog.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bliindaidating/app_constants.dart'; // For AppConstants for theme colors and spacing
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import ThemeController
import 'package:provider/provider.dart'; // For accessing ThemeController

/// A floating help icon that opens a modal dialog explaining the app's purpose.
///
/// This widget displays a '?' icon at the bottom right of the screen.
/// Tapping it opens an [AlertDialog] with a title and description,
/// styled according to the current theme (light/dark mode).
class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    // Determine colors based on current theme
    final Color iconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;
    final Color dialogBackgroundColor = isDarkMode ? AppConstants.dialogBackgroundColor : AppConstants.lightDialogBackgroundColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color borderColor = isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor;

    return FloatingActionButton(
      onPressed: () {
        // Pass theme-dependent colors to the dialog method
        _showHelpDialog(context, isDarkMode, dialogBackgroundColor, textColor, textHighEmphasis, borderColor);
      },
      backgroundColor: isDarkMode ? AppConstants.primaryColor.withOpacity(0.8) : AppConstants.primaryColor,
      foregroundColor: iconColor,
      elevation: 8.0,
      shape: const CircleBorder(),
      child: FaIcon(
        FontAwesomeIcons.question,
        size: AppConstants.fontSizeLarge,
        color: iconColor,
      ),
    );
  }

  /// Displays the help dialog.
  ///
  /// The dialog provides a brief explanation of the app's purpose
  /// and is styled to match the current theme.
  void _showHelpDialog(
    BuildContext context,
    bool isDarkMode,
    Color dialogBackgroundColor,
    Color textColor,
    Color textHighEmphasis,
    Color borderColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(
              color: borderColor.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          title: Text(
            'Welcome to Blind AI Dating',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppConstants.fontSizeExtraLarge,
              fontWeight: FontWeight.bold,
              color: textHighEmphasis,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Discover meaningful connections beyond superficial appearances. Our revolutionary AI matchmaking system focuses on deep compatibility, values, and shared interests to help you find your true soulmate.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppConstants.fontSizeMedium,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'We arrange personalized dates based on your availability and location, ensuring a seamless and stress-free experience. Your privacy and security are our top priorities, creating a safe and authentic environment for every interaction.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppConstants.fontSizeMedium,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'Explore, connect, and let our AI guide you to your destiny!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: textHighEmphasis,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Got It!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppConstants.fontSizeMedium,
                  color: isDarkMode ? AppConstants.primaryColor : AppConstants.primaryColor, // Button color always primary
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
