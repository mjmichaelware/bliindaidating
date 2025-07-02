// lib/screens/settings/widgets/notification_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For colors/theming (excluding removed ones)
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class NotificationSettings extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const NotificationSettings({super.key, required this.formKey});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _newMatchNotifications = true;
  bool _messageNotifications = true;
  bool _eventReminders = true;
  bool _appUpdates = true;
  bool _promoNotifications = false;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    // Hardcoded colors for AppConstants replacements
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? Colors.deepPurple.shade800 : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor, // Using hardcoded textColor
              ),
            ),
            const SizedBox(height: 24),
            _buildNotificationToggle('New Matches', _newMatchNotifications, (value) { setState(() => _newMatchNotifications = value); }, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildNotificationToggle('Messages', _messageNotifications, (value) { setState(() => _messageNotifications = value); }, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildNotificationToggle('Event Reminders', _eventReminders, (value) { setState(() => _eventReminders = value); }, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildNotificationToggle('App Updates & News', _appUpdates, (value) { setState(() => _appUpdates = value); }, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildNotificationToggle('Promotional Offers', _promoNotifications, (value) { setState(() => _promoNotifications = value); }, isDarkMode, textTheme, secondaryColor, cardColor),
            const SizedBox(height: 24),
            Text(
              'Customize how you receive alerts from BliindAIDating.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: textColor.withOpacity(0.6)), // Using hardcoded textColor
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(String title, bool value, Function(bool) onChanged, bool isDarkMode, TextTheme textTheme, Color secondaryColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: isDarkMode ? Colors.white : Colors.black87), // Using hardcoded textColor
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: secondaryColor, // Using hardcoded secondaryColor
            inactiveThumbColor: cardColor, // Using hardcoded cardColor
            inactiveTrackColor: cardColor.withOpacity(0.5), // Using hardcoded cardColor
          ),
        ],
      ),
    );
  }
}