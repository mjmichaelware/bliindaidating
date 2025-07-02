// lib/screens/settings/widgets/dating_preferences_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class DatingPreferencesForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? preferredGender;
  final RangeValues ageRange;
  final double maxDistance; // in miles
  final Function(String?) onPreferredGenderChanged;
  final Function(RangeValues) onAgeRangeChanged;
  final Function(double) onMaxDistanceChanged;

  const DatingPreferencesForm({
    super.key,
    required this.formKey,
    this.preferredGender,
    required this.ageRange,
    required this.maxDistance,
    required this.onPreferredGenderChanged,
    required this.onAgeRangeChanged,
    required this.onMaxDistanceChanged,
  });

  @override
  State<DatingPreferencesForm> createState() => _DatingPreferencesFormState();
}

class _DatingPreferencesFormState extends State<DatingPreferencesForm> {
  final List<String> _genderOptions = [
    'Male', 'Female', 'Non-binary', 'Any', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit', 'Demigirl', 'Demiboy',
    'Intersex', 'Other', 'Prefer not to say'
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87; // Main text color
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54; // Label/hint text color
    final Color widgetBackgroundColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor; // Background for dropdown menu/input fields

    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color inactiveColor = (isDarkMode ? Colors.deepPurple.shade800 : Colors.grey.shade200).withOpacity(0.5);


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dating Preferences',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: widget.preferredGender,
              decoration: InputDecoration(
                labelText: 'Preferred Gender',
                labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor), // Adjusted label color
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.people, color: secondaryTextColor), // Adjusted icon color
                enabledBorder: OutlineInputBorder( // Ensure border is visible
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder( // Ensure focused border is vibrant
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
              dropdownColor: widgetBackgroundColor, // Explicitly set dropdown background
              style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor), // Explicitly set selected item text color
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor)), // Explicitly set list item text color
                );
              }).toList(),
              onChanged: widget.onPreferredGenderChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a preferred gender.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Age Range: ${widget.ageRange.start.toInt()} - ${widget.ageRange.end.toInt()}',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'Inter',
                color: primaryTextColor,
              ),
            ),
            RangeSlider(
              values: widget.ageRange,
              min: 18,
              max: 99,
              divisions: 81,
              labels: RangeLabels(
                widget.ageRange.start.toInt().toString(),
                widget.ageRange.end.toInt().toString(),
              ),
              onChanged: widget.onAgeRangeChanged,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Max Distance: ${widget.maxDistance.toInt()} miles',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'Inter',
                color: primaryTextColor,
              ),
            ),
            Slider(
              value: widget.maxDistance,
              min: 10,
              max: 500,
              divisions: 49,
              label: widget.maxDistance.toInt().toString(),
              onChanged: widget.onMaxDistanceChanged,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}