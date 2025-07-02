// lib/screens/settings/widgets/dating_preferences_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // For colors/theming (excluding removed ones)
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
  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Any', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit', 'Demigirl', 'Demiboy',
    'Intersex', 'Other', 'Prefer not to say'
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
              'Dating Preferences',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor, // Using hardcoded textColor
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: widget.preferredGender,
              decoration: InputDecoration(
                labelText: 'Preferred Gender',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.people),
                labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
              ),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
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
                color: textColor, // Using hardcoded textColor
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
              activeColor: secondaryColor, // Using hardcoded secondaryColor
              inactiveColor: cardColor.withOpacity(0.5), // Using hardcoded cardColor
            ),
            const SizedBox(height: 24),
            Text(
              'Max Distance: ${widget.maxDistance.toInt()} miles',
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'Inter',
                color: textColor, // Using hardcoded textColor
              ),
            ),
            Slider(
              value: widget.maxDistance,
              min: 10,
              max: 500,
              divisions: 49,
              label: widget.maxDistance.toInt().toString(),
              onChanged: widget.onMaxDistanceChanged,
              activeColor: secondaryColor, // Using hardcoded secondaryColor
              inactiveColor: cardColor.withOpacity(0.5), // Using hardcoded cardColor
            ),
          ],
        ),
      ),
    );
  }
}