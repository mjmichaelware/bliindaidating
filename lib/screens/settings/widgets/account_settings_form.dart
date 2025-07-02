// lib/screens/settings/widgets/account_settings_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For colors/theming (excluding removed ones)
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class AccountSettingsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const AccountSettingsForm({super.key, required this.formKey});

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
              'Account Settings',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor, // Using hardcoded textColor
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text('Change Password', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)), // Using hardcoded textColor
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor), // Using hardcoded iconColor
              onTap: () {
                // TODO: Implement change password flow
                debugPrint('Change Password clicked');
              },
            ),
            ListTile(
              title: Text('Change Email', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)), // Using hardcoded textColor
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor), // Using hardcoded iconColor
              onTap: () {
                // TODO: Implement change email flow
                debugPrint('Change Email clicked');
              },
            ),
            ListTile(
              title: Text('Manage Payment Methods', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)), // Using hardcoded textColor
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor), // Using hardcoded iconColor
              onTap: () {
                // TODO: Implement payment methods management
                debugPrint('Manage Payment Methods clicked');
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement account deletion confirmation dialog and logic
                debugPrint('Delete Account clicked');
              },
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: Text('Delete Account', style: textTheme.labelLarge?.copyWith(fontFamily: 'Inter', color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Deleting your account is permanent and cannot be undone.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: Colors.red.shade200),
            ),
          ],
        ),
      ),
    );
  }
}