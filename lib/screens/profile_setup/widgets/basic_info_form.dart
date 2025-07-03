import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:intl/intl.dart'; // For date formatting

class BasicInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController displayNameController;
  final TextEditingController heightController;
  final Function(DateTime?) onDateOfBirthSelected;
  final Function(String?) onGenderChanged;
  final DateTime? dateOfBirth;
  final String? gender;

  const BasicInfoForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.displayNameController,
    required this.heightController,
    required this.onDateOfBirthSelected,
    required this.onGenderChanged,
    this.dateOfBirth,
    this.gender,
  });

  @override
  State<BasicInfoForm> createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.9),
              cardColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Basic Information',
                      style: textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                  ),
                  Text(
                    'Blind AI Dating',
                    style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us a little about yourself to get started.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: widget.fullNameController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.person, color: secondaryTextColor),
                  hintText: 'John Doe',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.displayNameController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.badge, color: secondaryTextColor),
                  hintText: 'Your public name',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: TextEditingController(
                  text: widget.dateOfBirth != null ? DateFormat.yMMMd().format(widget.dateOfBirth!) : '',
                ),
                readOnly: true,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.calendar_today, color: secondaryTextColor),
                  hintText: 'Select your birth date',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18 years old
                  );
                  if (pickedDate != null) {
                    widget.onDateOfBirthSelected(pickedDate);
                  }
                },
                validator: (value) {
                  if (widget.dateOfBirth == null) {
                    return 'Please select your date of birth.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: widget.gender,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.wc, color: secondaryTextColor),
                ),
                items: <String>['Male', 'Female', 'Non-binary', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onGenderChanged(newValue);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.heightController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Height (in cm)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.height, color: secondaryTextColor),
                  hintText: 'e.g., 175',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your height.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number for height.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
