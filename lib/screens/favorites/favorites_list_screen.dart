// lib/screens/favorites/favorites_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
// Note: This screen might eventually use LoadingIndicatorWidget and EmptyStateWidget
// but for now, we'll keep it minimal to resolve the constructor error.

class FavoritesListScreen extends StatelessWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.primaryColorShade900 : AppConstants.lightPrimaryColorShade400,
        iconTheme: IconThemeData(color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
      ),
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: 80,
                color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                'This is the Favorites List Screen (Placeholder)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  fontSize: AppConstants.fontSizeLarge,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'View and manage your favorite profiles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                  fontSize: AppConstants.fontSizeBody,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}