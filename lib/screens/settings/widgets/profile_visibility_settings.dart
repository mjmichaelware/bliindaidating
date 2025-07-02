// lib/screens/settings/widgets/profile_visibility_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
// Removed: import 'package:bliindaidating/screens/settings/widgets/dating_preferences_form.dart'; // THIS WAS THE PROBLEM!

class ProfileVisibilitySettings extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool showFullName;
  final bool showDisplayName;
  final bool showAge;
  final bool showGender;
  final bool showBio;
  final bool showSexualOrientation;
  final bool showHeight;
  final bool showInterests;
  final bool showLookingFor;
  final bool showLocation;

  final Function(bool) onShowFullNameChanged;
  final Function(bool) onShowDisplayNameChanged;
  final Function(bool) onShowAgeChanged;
  final Function(bool) onShowGenderChanged;
  final Function(bool) onShowBioChanged;
  final Function(bool) onShowSexualOrientationChanged;
  final Function(bool) onShowHeightChanged;
  final Function(bool) onShowInterestsChanged;
  final Function(bool) onShowLookingForChanged;
  final Function(bool) onShowLocationChanged;


  const ProfileVisibilitySettings({
    super.key,
    required this.formKey,
    required this.showFullName,
    required this.showDisplayName,
    required this.showAge,
    required this.showGender,
    required this.showBio,
    required this.showSexualOrientation,
    required this.showHeight,
    required this.showInterests,
    required this.showLookingFor,
    required this.showLocation,
    required this.onShowFullNameChanged,
    required this.onShowDisplayNameChanged,
    required this.onShowAgeChanged,
    required this.onShowGenderChanged,
    required this.onShowBioChanged,
    required this.onShowSexualOrientationChanged,
    required this.onShowHeightChanged,
    required this.onShowInterestsChanged,
    required this.onShowLookingForChanged,
    required this.onShowLocationChanged,
  });

  @override
  State<ProfileVisibilitySettings> createState() => _ProfileVisibilitySettingsState();
}

class _ProfileVisibilitySettingsState extends State<ProfileVisibilitySettings> {
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

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
              'Profile Visibility',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Control which information is visible on your blurred profile card.',
              style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),
            _buildVisibilityToggle('Full Legal Name', widget.showFullName, widget.onShowFullNameChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Display Name', widget.showDisplayName, widget.onShowDisplayNameChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Age', widget.showAge, widget.onShowAgeChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Gender', widget.showGender, widget.onShowGenderChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('About Me (Bio)', widget.showBio, widget.onShowBioChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Sexual Orientation', widget.showSexualOrientation, widget.onShowSexualOrientationChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Height', widget.showHeight, widget.onShowHeightChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Interests', widget.showInterests, widget.onShowInterestsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Looking For', widget.showLookingFor, widget.onShowLookingForChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Location (ZIP/City)', widget.showLocation, widget.onShowLocationChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            const SizedBox(height: 24),
            Text(
              'Note: Your analysis photo, legal name, and verified contact info are always visible to the system for safety and compliance, but are not displayed publicly unless explicitly chosen.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: textColor.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(String title, bool value, Function(bool) onChanged, bool isDarkMode, TextTheme textTheme, Color secondaryColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: secondaryColor,
            inactiveThumbColor: cardColor,
            inactiveTrackColor: cardColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}