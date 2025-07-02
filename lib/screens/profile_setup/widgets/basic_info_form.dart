// lib/screens/profile_setup/widgets/basic_info_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';


class BasicInfoForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController displayNameController;
  final TextEditingController heightController;
  final Function(DateTime?) onDateOfBirthSelected;
  final Function(String?) onGenderChanged;
  final DateTime? dateOfBirth;
  final String? gender;
  final GlobalKey<FormState> formKey;

  const BasicInfoForm({
    super.key,
    required this.fullNameController,
    required this.displayNameController,
    required this.heightController,
    required this.onDateOfBirthSelected,
    required this.onGenderChanged,
    this.dateOfBirth,
    this.gender,
    required this.formKey,
  });

  @override
  State<BasicInfoForm> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit',
    'Demigirl', 'Demiboy', 'Intersex', 'Other', 'Prefer not to say'
  ];

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && picked != widget.dateOfBirth) {
      widget.onDateOfBirthSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color widgetBackgroundColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              'This information helps us understand your core identity. You\'ll have full control over what\'s visible on your public profile card later in the app\'s settings.',
              style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: widget.fullNameController,
              style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
              decoration: InputDecoration(
                labelText: 'Full Legal Name',
                labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge, color: secondaryTextColor),
                hintText: 'As per your legal documents',
                hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full legal name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.displayNameController,
              style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
              decoration: InputDecoration(
                labelText: 'Display Name (Nickname)',
                labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: secondaryTextColor),
                hintText: 'How you want to appear in the app',
                hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a display name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                widget.dateOfBirth == null
                    ? 'Select Date of Birth (Age 18+ Required)'
                    : 'Date of Birth: ${DateFormat('yyyy-MM-dd').format(widget.dateOfBirth!)}',
                style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
              ),
              subtitle: Text(
                'This is required for age verification and matching to compatible age groups.',
                style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.8)),
              ),
              trailing: Icon(Icons.calendar_today, color: secondaryTextColor),
              onTap: () => _selectDateOfBirth(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.gender,
              decoration: InputDecoration(
                labelText: 'Gender Identity',
                labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.transgender, color: secondaryTextColor),
                hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
              dropdownColor: widgetBackgroundColor,
              style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  widget.onGenderChanged(newValue);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender identity.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.heightController,
              style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
              decoration: InputDecoration(
                labelText: 'Height (in cm or inches)',
                labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.height, color: secondaryTextColor),
                hintText: 'e.g., 175 cm or 5\' 9"',
                hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your height.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}