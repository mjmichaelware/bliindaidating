// lib/screens/newsfeed/newsfeed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NewsfeedScreen extends StatelessWidget {
  const NewsfeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Container(
      color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      child: Center(
        child: Text(
          'Newsfeed (Content Coming Soon)',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            fontSize: AppConstants.fontSizeLarge,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}