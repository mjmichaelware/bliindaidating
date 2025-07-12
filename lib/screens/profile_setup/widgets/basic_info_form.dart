// lib/screens/profile_setup/widgets/basic_info_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

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
  // List of common gender options, can be expanded if needed
  final List<String> _genderOptions = [
    'Male', 'Female', 'Non-binary', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit',
    'Demigirl', 'Demiboy', 'Intersex', 'Other', 'Prefer not to say'
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    // Define theme-dependent colors for consistent UI
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final Color inputFillColor = isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final Color inputBorderColor = secondaryTextColor.withOpacity(0.3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium), // Consistent padding
      child: Container(
        // Apply the beautiful background, border, shadow, and gradient
        decoration: BoxDecoration(
          color: cardColor, // Base background color for the form panel
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2), // Subtle glow effect
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient( // Elegant gradient for depth
            colors: [
              cardColor.withOpacity(0.9), // Slightly transparent to show background
              cardColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all( // Subtle border for definition
            color: (isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingLarge), // Inner padding for form content
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title and App Name/Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Basic Information',
                      style: textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        fontSize: AppConstants.fontSizeExtraLarge, // Larger font for section title
                      ),
                    ),
                  ),
                  // App Name and Icon for branding
                  Row(
                    children: [
                      Text(
                        'Blind AI Dating',
                        style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      SvgPicture.asset(
                        'assets/svg/DrawKit Vector Illustration Love & Dating (1).svg', // Example SVG for Basic Info
                        height: 40, // Adjust size as needed
                        semanticsLabel: 'Basic Info Icon',
                        colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn), // Apply theme color
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Tell us a little about yourself to get started. This information forms the core of your profile.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: AppConstants.spacingLarge), // Increased spacing

              // Full Name Input Field
              TextFormField(
                controller: widget.fullNameController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Full Name (Private)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.badge, color: secondaryTextColor),
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
              const SizedBox(height: AppConstants.spacingMedium),

              // Display Name Input Field
              TextFormField(
                controller: widget.displayNameController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Display Name (Public)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.person_outline, color: secondaryTextColor),
                  hintText: 'Your public name (e.g., "JDating")',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Date of Birth Selector
              TextFormField(
                controller: TextEditingController(
                  text: widget.dateOfBirth != null ? DateFormat.yMMMd().format(widget.dateOfBirth!) : '',
                ),
                readOnly: true, // Make it read-only to open date picker on tap
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.calendar_today, color: secondaryTextColor),
                  hintText: 'Select your birth date',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                onTap: () async {
                  // Show date picker when the text field is tapped
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
                    firstDate: DateTime(1900), // Earliest possible birth year
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // User must be at least 18 years old
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: activeColor, // Header background color
                            onPrimary: isDarkMode ? Colors.black : Colors.white, // Header text color
                            onSurface: primaryTextColor, // Calendar text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: activeColor, // Button text color
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    widget.onDateOfBirthSelected(pickedDate); // Call the callback with the selected date
                  }
                },
                validator: (value) {
                  if (widget.dateOfBirth == null) {
                    return 'Please select your date of birth.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: widget.gender,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                dropdownColor: cardColor, // Dropdown menu background
                decoration: InputDecoration(
                  labelText: 'Gender Identity',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.wc, color: secondaryTextColor),
                ),
                items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor, fontFamily: 'Inter')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onGenderChanged(newValue); // Call the callback with the new value
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender identity.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Height Input Field
              TextFormField(
                controller: widget.heightController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Height (in cm)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.height, color: secondaryTextColor),
                  hintText: 'e.g., 175',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                keyboardType: TextInputType.number, // Ensure numeric input
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
              const SizedBox(height: AppConstants.spacingMedium), // Final spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}