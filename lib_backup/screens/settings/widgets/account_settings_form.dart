// lib/screens/settings/widgets/account_settings_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // Still imported for general theme constants if they exist
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const AccountSettingsForm({super.key, required this.formKey});

  void _showChangePasswordDialog(BuildContext context, bool isDarkMode, TextTheme textTheme) {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController = TextEditingController();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    // Hardcoded colors for the dialog specific to this file
    final Color dialogTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color dialogHintColor = dialogTextColor.withOpacity(0.7);
    final Color dialogSecondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color dialogOnSecondaryColor = Colors.white; // Common for text on colored buttons

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Change Password', style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', color: dialogTextColor)),
          backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogHintColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your old password' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: '8+ chars, incl. A-Z, a-z, 0-9',
                    labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogHintColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || (value ?? []).isEmpty) return 'New password cannot be empty.';
                    if (value.length < 8) return 'Password must be at least 8 characters.';
                    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain uppercase.';
                    if (!value.contains(RegExp(r'[a-z]'))) return 'Must contain lowercase.';
                    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a digit.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogHintColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text) return 'Passwords do not match.';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: dialogSecondaryColor)), // Hardcoded
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  debugPrint('Change Password submitted (mock): Old: ${oldPasswordController.text}, New: ${newPasswordController.text}');
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password change requested. (Mock)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: dialogSecondaryColor), // Hardcoded
              child: Text('Change', style: TextStyle(color: dialogOnSecondaryColor)), // Hardcoded
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog(BuildContext context, bool isDarkMode, TextTheme textTheme) {
    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController passwordConfirmationController = TextEditingController();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    // Hardcoded colors for the dialog specific to this file
    final Color dialogTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color dialogHintColor = dialogTextColor.withOpacity(0.7);
    final Color dialogSecondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color dialogOnSecondaryColor = Colors.white;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Change Email', style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', color: dialogTextColor)),
          backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'New Email',
                    hintText: 'your.new.email@example.com',
                    labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogHintColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || (value ?? []).isEmpty) return 'New email cannot be empty.';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email address.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordConfirmationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogHintColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your current password to confirm' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: dialogSecondaryColor)), // Hardcoded
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  debugPrint('Change Email submitted (mock): New: ${newEmailController.text}, Password confirmed.');
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email change requested. Check your new email for verification. (Mock)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: dialogSecondaryColor), // Hardcoded
              child: Text('Change', style: TextStyle(color: dialogOnSecondaryColor)), // Hardcoded
            ),
          ],
        );
      },
    );
  }

  void _showManagePaymentMethodsDialog(BuildContext context, bool isDarkMode, TextTheme textTheme) {
    // Hardcoded colors for the dialog specific to this file
    final Color dialogTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color dialogIconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final Color dialogSecondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Manage Payment Methods', style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', color: dialogTextColor)),
          backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This section would integrate with a payment gateway (e.g., Stripe, Paddle) to allow you to add, update, or remove your payment information for premium subscriptions.',
                  style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: dialogTextColor.withOpacity(0.8))),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.add_card, color: dialogIconColor),
                title: Text('Add New Card', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: dialogTextColor)),
                onTap: () {
                  debugPrint('Add New Card clicked (mock)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigating to card input form. (Mock)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                  );
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.payment, color: dialogIconColor),
                title: Text('View Existing Methods', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: dialogTextColor)),
                onTap: () {
                  debugPrint('View Existing Methods clicked (mock)');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Displaying list of saved cards. (Mock)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                  );
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Close', style: TextStyle(color: dialogSecondaryColor)), // Hardcoded
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;


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
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text('Change Password', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)),
              subtitle: Text('Update your account password.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
              onTap: () => _showChangePasswordDialog(context, isDarkMode, textTheme),
            ),
            ListTile(
              title: Text('Change Email', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)),
              subtitle: Text('Update your registered email address.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
              onTap: () => _showChangeEmailDialog(context, isDarkMode, textTheme),
            ),
            ListTile(
              title: Text('Manage Payment Methods', style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: textColor)),
              subtitle: Text('Add or remove payment information for premium features.', style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7))),
              trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
              onTap: () => _showManagePaymentMethodsDialog(context, isDarkMode, textTheme),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('Delete Account clicked');
                 showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete Account'),
                      content: Text(
                        'Are you sure you want to permanently delete your account? This action cannot be undone.',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                      backgroundColor: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
                      titleTextStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20, color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor),
                      contentTextStyle: TextStyle(fontFamily: 'Inter', color: isDarkMode ? AppConstants.textColor.withOpacity(0.8) : AppConstants.lightTextColor.withOpacity(0.8)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text('Cancel', style: TextStyle(color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            debugPrint('Account deletion confirmed (mock).');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Account deletion requested. (Mock)', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                          child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  },
                );
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