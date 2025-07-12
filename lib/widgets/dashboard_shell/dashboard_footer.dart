// lib/widgets/dashboard_shell/dashboard_footer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for internal navigation
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart'; // No longer needed for internal routes
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class DashboardFooter extends StatelessWidget {
  const DashboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final TextStyle footerTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: AppConstants.fontSizeSmall,
      color: isDarkMode ? AppConstants.textColor.withOpacity(0.6) : AppConstants.lightTextColor.withOpacity(0.6),
    );

    final ButtonStyle footerButtonStyle = TextButton.styleFrom(
      foregroundColor: isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: AppConstants.fontSizeSmall,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
            style: footerTextStyle,
          ),
          SizedBox(height: AppConstants.spacingSmall),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppConstants.spacingSmall,
            runSpacing: AppConstants.spacingExtraSmall,
            children: [
              TextButton(
                onPressed: () {
                  context.go('/privacy'); // Use context.go for internal routing
                },
                style: footerButtonStyle,
                child: const Text('Privacy Policy'),
              ),
              Text(
                '|',
                style: footerTextStyle,
              ),
              TextButton(
                onPressed: () {
                  context.go('/terms'); // Use context.go for internal routing
                },
                style: footerButtonStyle,
                child: const Text('Terms & Conditions'),
              ),
              Text(
                '|',
                style: footerTextStyle,
              ),
              TextButton(
                onPressed: () {
                  context.go('/about-us'); // Use context.go for internal routing
                },
                style: footerButtonStyle,
                child: const Text('About Us'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}