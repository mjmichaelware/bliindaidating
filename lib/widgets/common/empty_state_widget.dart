// lib/widgets/common/empty_state_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart'; // Assuming AppConstants for colors/fonts
import 'package:bliindaidating/controllers/theme_controller.dart'; // For theme access

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData? icon;
  final VoidCallback? onRefresh;
  final String refreshButtonText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subMessage,
    this.icon,
    this.onRefresh,
    this.refreshButtonText = 'Refresh',
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color iconColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color buttonColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color buttonTextColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],
          Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: AppConstants.fontSizeMedium,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              subMessage!,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: AppConstants.fontSizeSmall,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRefresh != null) ...[
            const SizedBox(height: AppConstants.spacingLarge),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
              ),
              child: Text(refreshButtonText),
            ),
          ],
        ],
      ),
    );
  }
}