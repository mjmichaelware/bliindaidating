// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/lifestyle_and_values_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

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
  String? _fitnessLevel; // This maps to exerciseFrequencyOrFitnessLevel in UserProfile
  String? _dietaryPreference; // This maps to diet in UserProfile
  final List<String> _habits = []; // This maps to sleepSchedule or other specific habits in UserProfile

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
    required bool isSmallScreen, // Added for responsiveness
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color hintColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);
    final Color dropdownColor = isDarkMode ? AppConstants.cardColor.withOpacity(0.95) : AppConstants.lightCardColor.withOpacity(0.95);
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor; // Consistent active color

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
          labelStyle: TextStyle(color: hintColor, fontFamily: 'Inter', fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium),
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
            borderSide: BorderSide(color: activeColor, width: 2.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium),
        ),
        dropdownColor: dropdownColor,
        style: TextStyle(color: textColor, fontFamily: 'Inter', fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium),
        icon: Icon(Icons.arrow_drop_down_rounded, color: hintColor, size: isSmallScreen ? AppConstants.fontSizeLarge : AppConstants.fontSizeExtraLarge),
        isExpanded: true,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium)),
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
    required bool isSmallScreen, // Added for responsiveness
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color hintColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color fillColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.7) : AppConstants.lightSurfaceColor.withOpacity(0.7);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.4) : AppConstants.lightBorderColor.withOpacity(0.6);
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor; // Consistent active color

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
        style: TextStyle(color: textColor, fontFamily: 'Inter', fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hintColor, fontFamily: 'Inter', fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium),
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
            borderSide: BorderSide(color: activeColor, width: 2.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium),
        ),
        cursorColor: activeColor,
      ),
    );
  }

  /// Builds a themed checkbox list tile for multiple selections.
  Widget _buildThemedCheckboxListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDarkMode,
    required bool isSmallScreen, // Added for responsiveness
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color activeColor = AppConstants.secondaryColor;
    final Color checkColor = isDarkMode ? Colors.black : Colors.white; // Checkmark color
    final Color tileColor = isDarkMode ? AppConstants.surfaceColor.withOpacity(0.5) : AppConstants.lightSurfaceColor.withOpacity(0.5); // Subtle background for the tile

    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Inter',
          fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
      tileColor: tileColor, // Apply tile background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)), // Rounded corners for tile
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
      contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? AppConstants.paddingExtraSmall : AppConstants.paddingSmall, vertical: AppConstants.paddingExtraSmall), // Adjusted padding
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600; // Determine screen size

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textHighEmphasis = isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _formFieldSlideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium), // Responsive padding
          child: Container( // Wrap with Container for custom background/shadows
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
            padding: EdgeInsets.all(isSmallScreen ? AppConstants.paddingMedium : AppConstants.paddingLarge), // Inner padding for content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Title and App Name/Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _glowPulseAnimation,
                        builder: (context, child) {
                          return Text(
                            'Your Lifestyle & Values',
                            style: TextStyle(
                              fontSize: isSmallScreen ? AppConstants.fontSizeLarge : AppConstants.fontSizeHeadline, // Responsive font size
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
                            overflow: TextOverflow.ellipsis, // Prevent overflow
                            maxLines: 2, // Allow title to wrap
                          );
                        },
                      ),
                    ),
                    // App Name and Icon for branding (adjusted for small screens)
                    if (!isSmallScreen) // Only show on larger screens to save space
                      Row(
                        children: [
                          Text(
                            'Blind AI Dating',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7)),
                          ),
                          const SizedBox(width: AppConstants.spacingSmall),
                          SvgPicture.asset(
                            'assets/svg/DrawKit Vector Illustration Love & Dating (7).svg', // Example SVG for Lifestyle/Values
                            height: 40,
                            semanticsLabel: 'Lifestyle Icon',
                            colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium), // Responsive spacing
                Text(
                  'Share insights into your daily life, social preferences, and what truly matters to you. This helps us find partners who align with your core values.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.8), fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeBody), // Responsive font size
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Social Preference Dropdown
                _buildThemedDropdown(
                  label: 'How do you prefer to socialize?',
                  items: const [
                    'Extrovert (love large groups)',
                    'Introvert (prefer small, intimate settings)',
                    'Ambivert (mix of both)',
                    'Homebody',
                    'Prefer not to say', // Added option
                  ],
                  value: _socialPreference,
                  onChanged: (newValue) {
                    setState(() {
                      _socialPreference = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Fitness Level Dropdown (Maps to exerciseFrequencyOrFitnessLevel)
                _buildThemedDropdown(
                  label: 'What is your general fitness level?',
                  items: const [
                    'Very Active (daily exercise)',
                    'Moderately Active (regular exercise)',
                    'Occasionally Active (some exercise)',
                    'Sedentary (minimal exercise)',
                    'Prefer not to say', // Added option
                  ],
                  value: _fitnessLevel,
                  onChanged: (newValue) {
                    setState(() {
                      _fitnessLevel = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Dietary Preference Dropdown (Maps to diet)
                _buildThemedDropdown(
                  label: 'Do you have any dietary preferences?',
                  items: const [
                    'No specific preference',
                    'Vegetarian',
                    'Vegan',
                    'Pescatarian',
                    'Keto',
                    'Gluten-free',
                    'Halal', // Added common preference
                    'Kosher', // Added common preference
                    'Other',
                    'Prefer not to say', // Added option
                  ],
                  value: _dietaryPreference,
                  onChanged: (newValue) {
                    setState(() {
                      _dietaryPreference = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Daily Routine Text Field
                _buildThemedTextField(
                  controller: _dailyRoutineController,
                  label: 'Describe your typical daily routine (Optional)',
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  maxLines: 3,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Important Values Text Field
                _buildThemedTextField(
                  controller: _importantValuesController,
                  label: 'What are 3-5 values most important to you in life and a partner?',
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  maxLines: 3,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Stress Management Text Field
                _buildThemedTextField(
                  controller: _stressManagementController,
                  label: 'How do you typically manage stress? (Optional)', // Made optional
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  maxLines: 2,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Habits Checkboxes
                Text(
                  'Which of these habits apply to you?',
                  style: TextStyle(
                    fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium), // Responsive spacing
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildThemedCheckboxListTile(
                      title: 'Enjoys quiet nights in',
                      value: _habits.contains('Enjoys quiet nights in'),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _habits.add('Enjoys quiet nights in');
                          } else {
                            _habits.remove('Enjoys quiet nights in');
                          }
                        });
                      },
                      isDarkMode: isDarkMode,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildThemedCheckboxListTile(
                      title: 'Loves to travel',
                      value: _habits.contains('Loves to travel'),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            _habits.add('Loves to travel');
                          } else {
                            _habits.remove('Loves to travel');
                          }
                        });
                      },
                      isDarkMode: isDarkMode,
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium), // Final spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}