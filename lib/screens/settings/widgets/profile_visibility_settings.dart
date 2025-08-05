// lib/screens/settings/widgets/profile_visibility_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class ProfileVisibilitySettings extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserProfile profile;
  final Map<String, bool> initialVisibility;
  final ValueChanged<Map<String, bool>> onVisibilityChange;

  const ProfileVisibilitySettings({
    Key? key,
    required this.formKey,
    required this.profile,
    required this.initialVisibility,
    required this.onVisibilityChange,
  }) : super(key: key);

  @override
  _ProfileVisibilitySettingsState createState() => _ProfileVisibilitySettingsState();
}

class _ProfileVisibilitySettingsState extends State<ProfileVisibilitySettings> {
  late Map<String, bool> _visibilityPreferences;
  late final List<String> _profileFields;

  @override
  void initState() {
    super.initState();
    // Use the initial preferences or create a default set
    _visibilityPreferences = Map.from(widget.initialVisibility);
    
    // Dynamically get a list of fields from the UserProfile model
    // and exclude fields that should always be private or public
    final profileMap = widget.profile.toJson();
    _profileFields = profileMap.keys.where((key) {
      // Exclude system fields or fields that don't make sense to be private
      return !AppConstants.excludedProfileFields.contains(key);
    }).toList();

    // Ensure all fields have a default value
    for (var field in _profileFields) {
      _visibilityPreferences.putIfAbsent(field, () => true); // Default to public
    }
  }

  String _formatFieldName(String key) {
    // A simple formatter to make field names more readable
    final formatted = key.replaceAll('_', ' ').replaceAllMapped(RegExp(r'\b[a-z]'), (match) => match.group(0)!.toUpperCase());
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey,
        child: ListView.builder(
          itemCount: _profileFields.length,
          itemBuilder: (context, index) {
            final fieldKey = _profileFields[index];
            return SwitchListTile(
              title: Text(
                _formatFieldName(fieldKey),
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              subtitle: Text(
                'This field will be visible on your public profile.',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
              ),
              value: _visibilityPreferences[fieldKey] ?? true,
              onChanged: (bool value) {
                setState(() {
                  _visibilityPreferences[fieldKey] = value;
                  widget.onVisibilityChange(_visibilityPreferences);
                });
              },
              activeColor: accentColor,
            );
          },
        ),
      ),
    );
  }
}
