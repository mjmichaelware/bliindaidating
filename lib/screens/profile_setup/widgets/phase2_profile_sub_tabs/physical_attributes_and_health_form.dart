import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations

/// A detailed form for users to specify their physical attributes and health details.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class PhysicalAttributesAndHealthForm extends StatefulWidget {
  const PhysicalAttributesAndHealthForm({super.key});

  @override
  State<PhysicalAttributesAndHealthForm> createState() => _PhysicalAttributesAndHealthFormState();
}

class _PhysicalAttributesAndHealthFormState extends State<PhysicalAttributesAndHealthForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _exerciseFrequencyController = TextEditingController();
  final TextEditingController _healthConcernsController = TextEditingController();

  // State variables for form selections
  String? _bodyType;
  String? _hairColor;
  String? _eyeColor;
  String? _smokingHabit;
  String? _drinkingHabit;
  String? _activityLevel;

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
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    _exerciseFrequencyController.dispose();
    _healthConcernsController.dispose();
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
                    'Physical Attributes & Health',
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

              // Height Input
              Text(
                'Your Height',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _heightFeetController,
                      label: 'Feet',
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _buildThemedTextField(
                      controller: _heightInchesController,
                      label: 'Inches',
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Weight Input
              _buildThemedTextField(
                controller: _weightController,
                label: 'Your Weight (lbs) (Optional)',
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Body Type Dropdown
              _buildThemedDropdown(
                label: 'Body Type',
                items: const [
                  'Slim',
                  'Athletic',
                  'Average',
                  'Curvy',
                  'Muscular',
                  'A few extra pounds',
                  'Full-figured',
                ],
                value: _bodyType,
                onChanged: (newValue) {
                  setState(() {
                    _bodyType = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Hair Color Dropdown
              _buildThemedDropdown(
                label: 'Hair Color',
                items: const [
                  'Black',
                  'Brown',
                  'Blonde',
                  'Red',
                  'Gray/White',
                  'Other',
                ],
                value: _hairColor,
                onChanged: (newValue) {
                  setState(() {
                    _hairColor = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Eye Color Dropdown
              _buildThemedDropdown(
                label: 'Eye Color',
                items: const [
                  'Brown',
                  'Blue',
                  'Green',
                  'Hazel',
                  'Gray',
                  'Other',
                ],
                value: _eyeColor,
                onChanged: (newValue) {
                  setState(() {
                    _eyeColor = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Smoking Habit Dropdown
              _buildThemedDropdown(
                label: 'Smoking Habit',
                items: const [
                  'Never',
                  'Socially',
                  'Occasionally',
                  'Regularly',
                ],
                value: _smokingHabit,
                onChanged: (newValue) {
                  setState(() {
                    _smokingHabit = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Drinking Habit Dropdown
              _buildThemedDropdown(
                label: 'Drinking Habit',
                items: const [
                  'Never',
                  'Socially',
                  'Occasionally',
                  'Regularly',
                  'Heavily',
                ],
                value: _drinkingHabit,
                onChanged: (newValue) {
                  setState(() {
                    _drinkingHabit = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Activity Level Dropdown
              _buildThemedDropdown(
                label: 'How active are you?',
                items: const [
                  'Sedentary (little to no exercise)',
                  'Lightly Active (light exercise/sports 1-3 days/week)',
                  'Moderately Active (moderate exercise/sports 3-5 days/week)',
                  'Very Active (hard exercise/sports 6-7 days/week)',
                  'Extremely Active (hard daily exercise/physical job)',
                ],
                value: _activityLevel,
                onChanged: (newValue) {
                  setState(() {
                    _activityLevel = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Health Concerns Text Field
              _buildThemedTextField(
                controller: _healthConcernsController,
                label: 'Any health concerns or conditions you\'d like to share? (Optional)',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
