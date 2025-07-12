// lib/screens/date/post_date_feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class PostDateFeedbackScreen extends StatelessWidget {
  const PostDateFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Date Feedback',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
        ),
      ),
      body: Container(
        color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        child: Center(
          child: Text(
            'Post-Date Feedback Questions (To be implemented)',
            style: TextStyle(
              color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
              fontSize: AppConstants.fontSizeLarge,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}