// lib/screens/profile/my_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
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
            'My Profile Page (Coming Soon)',
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