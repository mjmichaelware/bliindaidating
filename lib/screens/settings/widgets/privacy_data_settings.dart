// lib/screens/settings/widgets/privacy_data_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For colors/theming (excluding removed ones)
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class PrivacyDataSettings extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const PrivacyDataSettings({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    // Hardcoded colors for AppConstants replacements
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & Data',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor, // Using hardcoded textColor
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text('View Your Data', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)), // Using hardcoded textColor
              subtitle: Text('Download a copy of your personal data collected by the app.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))), // Using hardcoded textColor
              trailing: Icon(Icons.download, color: iconColor), // Using hardcoded iconColor
              onTap: () {
                // TODO: Implement data download logic
                debugPrint('View Your Data clicked');
              },
            ),
            ListTile(
              title: Text('Data Deletion Request', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)), // Using hardcoded textColor
              subtitle: Text('Request permanent deletion of all your data.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))), // Using hardcoded textColor
              trailing: Icon(Icons.delete_sweep, color: iconColor), // Using hardcoded iconColor
              onTap: () {
                // TODO: Implement data deletion request flow
                debugPrint('Data Deletion Request clicked');
              },
            ),
            const SizedBox(height: 24),
            Text(
              'We take your privacy seriously. For more information, please review our Privacy Policy.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: textColor.withOpacity(0.6)), // Using hardcoded textColor
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to Privacy Policy screen
                  debugPrint('Privacy Policy link clicked');
                },
                child: Text('Read Privacy Policy', style: textTheme.labelLarge?.copyWith(fontFamily: 'Inter', color: secondaryColor)), // Using hardcoded secondaryColor
              ),
            ),
          ],
        ),
      ),
    );
  }
}