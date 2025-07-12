import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations

/// A detailed form for users to specify their personal and contact details.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class PersonalAndContactForm extends StatefulWidget {
  const PersonalAndContactForm({super.key});

  @override
  State<PersonalAndContactForm> createState() => _PersonalAndContactFormState();
}

class _PersonalAndContactFormState extends State<PersonalAndContactForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // State variables for form selections
  DateTime? _dateOfBirth;
  String? _gender;
  String? _pronouns;
  String? _ethnicity;

  // Animation controllers for various UI elements
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;

  late AnimationController _glowPulseController;
  late Animation<double> _glowPulseAnimation;

  late AnimationController _formFieldSlideController;
  late Animation<Offset> _formFieldSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade-in animation for the entire form
    _fadeInController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationLong,
    );
    _fadeInAnimation = CurvedAnimation(parent: _fadeInController, curve: Curves.easeOutQuad);

    // Initialize glow pulse animation for interactive elements
    _glowPulseController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationLong,
      reverseDuration: AppConstants.animationDurationMedium,
    )..repeat(reverse: true);
    _glowPulseAnimation = CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOutSine);

    // Initialize slide-in animation for form fields
    _formFieldSlideController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _formFieldSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1), // Starts slightly below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formFieldSlideController, curve: Curves.easeOutCubic));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeInController.forward();
        _formFieldSlideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _fadeInController.dispose();
    _glowPulseController.dispose();
    _formFieldSlideController.dispose();
    super.dispose();
  }

  /// Builds a custom dropdown menu for form selections.
  Widget _buildThemedDropdown({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color hintColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);
    final Color dropdownColor = isDarkMode ? AppConstants.cardColor.withOpacity(0.95) : AppConstants.lightCardColor.withOpacity(0.95);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hintColor, fontFamily: 'Inter'),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: AppConstants.secondaryColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
        ),
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor, fontFamily: 'Inter', fontSize: AppConstants.fontSizeMedium),
        icon: Icon(Icons.arrow_drop_down_rounded, color: hintColor),
        isExpanded: true,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a themed text input field.
  Widget _buildThemedTextField({
    required TextEditingController controller,
    required String label,
    required bool isDarkMode,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color hintColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor, fontFamily: 'Inter', fontSize: AppConstants.fontSizeMedium),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hintColor, fontFamily: 'Inter'),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            borderSide: BorderSide(color: AppConstants.secondaryColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
        ),
        cursorColor: AppConstants.secondaryColor,
      ),
    );
  }

  /// Shows a date picker for date of birth.
  Future<void> _selectDateOfBirth(BuildContext context, bool isDarkMode) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)), // 100 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: isDarkMode ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppConstants.secondaryColor, // Header background color
              onPrimary: AppConstants.textColor, // Header text color
              surface: AppConstants.cardColor, // Calendar background
              onSurface: AppConstants.textColor, // Calendar text color
            ),
            dialogBackgroundColor: AppConstants.dialogBackgroundColor,
          ) : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.secondaryColor, // Header background color
              onPrimary: AppConstants.lightTextColor, // Header text color
              surface: AppConstants.lightCardColor, // Calendar background
              onSurface: AppConstants.lightTextColor, // Calendar text color
            ),
            dialogBackgroundColor: AppConstants.lightDialogBackgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color hintColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);


    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _formFieldSlideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title with Animation
              AnimatedBuilder(
                animation: _glowPulseAnimation,
                builder: (context, child) {
                  return Text(
                    'Personal & Contact Information',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeHeadline,
                      fontWeight: FontWeight.bold,
                      color: Color.lerp(textHighEmphasis, secondaryColor, _glowPulseAnimation.value),
                      fontFamily: 'Inter',
                      shadows: [
                        BoxShadow(
                          color: secondaryColor.withOpacity(0.3 + 0.4 * _glowPulseAnimation.value),
                          blurRadius: 10.0 + 5.0 * _glowPulseAnimation.value,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Full Name
              _buildThemedTextField(
                controller: _fullNameController,
                label: 'Full Name',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Email Address
              _buildThemedTextField(
                controller: _emailController,
                label: 'Email Address',
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Phone Number
              _buildThemedTextField(
                controller: _phoneNumberController,
                label: 'Phone Number (Optional)',
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Date of Birth
              GestureDetector(
                onTap: () => _selectDateOfBirth(context, isDarkMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: hintColor),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Text(
                        _dateOfBirth == null
                            ? 'Select Date of Birth'
                            : 'Date of Birth: ${AppConstants.dateFormatter.format(_dateOfBirth!)}',
                        style: TextStyle(
                          color: _dateOfBirth == null ? hintColor : textColor,
                          fontFamily: 'Inter',
                          fontSize: AppConstants.fontSizeMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Gender Dropdown
              _buildThemedDropdown(
                label: 'Gender',
                items: const ['Male', 'Female', 'Non-binary', 'Prefer not to say', 'Other'],
                value: _gender,
                onChanged: (newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Pronouns Dropdown
              _buildThemedDropdown(
                label: 'Pronouns (Optional)',
                items: const ['He/Him', 'She/Her', 'They/Them', 'Prefer not to say', 'Other'],
                value: _pronouns,
                onChanged: (newValue) {
                  setState(() {
                    _pronouns = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Ethnicity Dropdown
              _buildThemedDropdown(
                label: 'Ethnicity (Optional)',
                items: const [
                  'White',
                  'Black or African American',
                  'Asian',
                  'Hispanic or Latino',
                  'Native American or Alaska Native',
                  'Native Hawaiian or Pacific Islander',
                  'Mixed',
                  'Prefer not to say',
                ],
                value: _ethnicity,
                onChanged: (newValue) {
                  setState(() {
                    _ethnicity = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Address Fields
              Text(
                'Current Address (Optional)',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              _buildThemedTextField(
                controller: _addressController,
                label: 'Street Address',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _cityController,
                      label: 'City',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _stateController,
                      label: 'State/Province',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _zipCodeController,
                      label: 'Zip/Postal Code',
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _countryController,
                      label: 'Country',
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
