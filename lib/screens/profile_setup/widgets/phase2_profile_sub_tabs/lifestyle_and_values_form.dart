import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations

/// A detailed form for users to specify their lifestyle and values.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class LifestyleAndValuesForm extends StatefulWidget {
  const LifestyleAndValuesForm({super.key});

  @override
  State<LifestyleAndValuesForm> createState() => _LifestyleAndValuesFormState();
}

class _LifestyleAndValuesFormState extends State<LifestyleAndValuesForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _dailyRoutineController = TextEditingController();
  final TextEditingController _importantValuesController = TextEditingController();
  final TextEditingController _stressManagementController = TextEditingController();

  // State variables for form selections
  String? _socialPreference;
  String? _fitnessLevel;
  String? _dietaryPreference;
  final List<String> _habits = [];

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
    _dailyRoutineController.dispose();
    _importantValuesController.dispose();
    _stressManagementController.dispose();
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

  /// Builds a themed checkbox list tile for multiple selections.
  Widget _buildThemedCheckboxListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDarkMode,
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color activeColor = AppConstants.secondaryColor;
    final Color checkColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Inter',
          fontSize: AppConstants.fontSizeMedium,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      tileColor: Colors.transparent, // Ensure it blends with the parent container
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
      contentPadding: EdgeInsets.zero, // Remove default padding
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

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
                    'Your Lifestyle & Values',
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

              // Social Preference Dropdown
              _buildThemedDropdown(
                label: 'How do you prefer to socialize?',
                items: const [
                  'Extrovert (love large groups)',
                  'Introvert (prefer small, intimate settings)',
                  'Ambivert (mix of both)',
                  'Homebody',
                ],
                value: _socialPreference,
                onChanged: (newValue) {
                  setState(() {
                    _socialPreference = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Fitness Level Dropdown
              _buildThemedDropdown(
                label: 'What is your general fitness level?',
                items: const [
                  'Very Active (daily exercise)',
                  'Moderately Active (regular exercise)',
                  'Occasionally Active (some exercise)',
                  'Sedentary (minimal exercise)',
                ],
                value: _fitnessLevel,
                onChanged: (newValue) {
                  setState(() {
                    _fitnessLevel = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Dietary Preference Dropdown
              _buildThemedDropdown(
                label: 'Do you have any dietary preferences?',
                items: const [
                  'No specific preference',
                  'Vegetarian',
                  'Vegan',
                  'Pescatarian',
                  'Keto',
                  'Gluten-free',
                  'Other',
                ],
                value: _dietaryPreference,
                onChanged: (newValue) {
                  setState(() {
                    _dietaryPreference = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Daily Routine Text Field
              _buildThemedTextField(
                controller: _dailyRoutineController,
                label: 'Describe your typical daily routine (Optional)',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Important Values Text Field
              _buildThemedTextField(
                controller: _importantValuesController,
                label: 'What are 3-5 values most important to you in life and a partner?',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Stress Management Text Field
              _buildThemedTextField(
                controller: _stressManagementController,
                label: 'How do you typically manage stress?',
                isDarkMode: isDarkMode,
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Habits Checkboxes
              Text(
                'Which of these habits apply to you?',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Column(
                children: [
                  _buildThemedCheckboxListTile(
                    title: 'Early Riser',
                    value: _habits.contains('Early Riser'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Early Riser');
                        } else {
                          _habits.remove('Early Riser');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Night Owl',
                    value: _habits.contains('Night Owl'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Night Owl');
                        } else {
                          _habits.remove('Night Owl');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Organized',
                    value: _habits.contains('Organized'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Organized');
                        } else {
                          _habits.remove('Organized');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Spontaneous',
                    value: _habits.contains('Spontaneous'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Spontaneous');
                        } else {
                          _habits.remove('Spontaneous');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Loves to cook',
                    value: _habits.contains('Loves to cook'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Loves to cook');
                        } else {
                          _habits.remove('Loves to cook');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Enjoys trying new restaurants',
                    value: _habits.contains('Enjoys trying new restaurants'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _habits.add('Enjoys trying new restaurants');
                        } else {
                          _habits.remove('Enjoys trying new restaurants');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
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
