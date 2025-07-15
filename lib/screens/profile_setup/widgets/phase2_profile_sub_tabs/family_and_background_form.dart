// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/family_and_background_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

/// A detailed form for users to specify their family and background details.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class FamilyAndBackgroundForm extends StatefulWidget {
  const FamilyAndBackgroundForm({super.key});

  @override
  State<FamilyAndBackgroundForm> createState() => _FamilyAndBackgroundFormState();
}

class _FamilyAndBackgroundFormState extends State<FamilyAndBackgroundForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _siblingsController = TextEditingController();
  final TextEditingController _childhoodDescriptionController = TextEditingController();
  final TextEditingController _culturalBackgroundController = TextEditingController();

  // State variables for form selections
  String? _familyImportance;
  String? _parentalStatus; // e.g., 'Parents together', 'Divorced', 'Single parent'
  bool _hasChildren = false;
  String? _childrenStatus; // e.g., 'Live with me', 'Live elsewhere', 'Adult children'
  bool _wantsChildren = false; // New field: Wants Children

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
    _siblingsController.dispose();
    _childhoodDescriptionController.dispose();
    _culturalBackgroundController.dispose();
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
            borderSide: BorderSide(color: activeColor, width: 2.0), // Use activeColor for focused border
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
            borderSide: BorderSide(color: activeColor, width: 2.0), // Use activeColor for focused border
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: isSmallScreen ? AppConstants.paddingSmall : AppConstants.paddingMedium),
        ),
        cursorColor: activeColor, // Consistent cursor color
      ),
    );
  }

  /// Builds a themed switch list tile.
  Widget _buildThemedSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
    required bool isSmallScreen, // Added for responsiveness
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color activeColor = AppConstants.secondaryColor;
    final Color inactiveThumbColor = isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis;
    final Color inactiveTrackColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;

    return SwitchListTile(
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
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      tileColor: Colors.transparent, // Ensure it blends with the parent container
      contentPadding: EdgeInsets.zero, // Remove default padding
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
                            'Your Family & Background',
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
                            'assets/svg/DrawKit Vector Illustration Love & Dating (10).svg', // Example SVG for Family
                            height: 40,
                            semanticsLabel: 'Family Icon',
                            colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium), // Responsive spacing
                Text(
                  'Share details about your family and upbringing. This helps us understand your values and background, contributing to deeper connections.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.8), fontSize: isSmallScreen ? AppConstants.fontSizeSmall : AppConstants.fontSizeBody), // Responsive font size
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Siblings Text Field
                _buildThemedTextField(
                  controller: _siblingsController,
                  label: 'How many siblings do you have? (Optional)',
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Family Importance Dropdown
                _buildThemedDropdown(
                  label: 'How important is family to you?',
                  items: const [
                    'Very important',
                    'Important',
                    'Moderately important',
                    'Less important',
                    'Not applicable',
                    'Prefer not to say', // Added option
                  ],
                  value: _familyImportance,
                  onChanged: (newValue) {
                    setState(() {
                      _familyImportance = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Parental Status Dropdown
                _buildThemedDropdown(
                  label: 'What is your parental status?',
                  items: const [
                    'Parents together',
                    'Parents divorced/separated',
                    'Single parent household',
                    'Guardian(s)',
                    'Other',
                    'Prefer not to say', // Added option
                  ],
                  value: _parentalStatus,
                  onChanged: (newValue) {
                    setState(() {
                      _parentalStatus = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Has Children Switch
                _buildThemedSwitchListTile(
                  title: 'Do you have children?',
                  value: _hasChildren,
                  onChanged: (bool value) {
                    setState(() {
                      _hasChildren = value;
                      if (!value) {
                        _childrenStatus = null; // Reset if no children
                      }
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                if (_hasChildren) ...[
                  SizedBox(height: isSmallScreen ? AppConstants.spacingSmall : AppConstants.spacingMedium), // Responsive spacing
                  // Children Status Dropdown (conditionally displayed)
                  _buildThemedDropdown(
                    label: 'Children live...',
                    items: const [
                      'Live with me full-time',
                      'Live with me part-time',
                      'Live elsewhere',
                      'Adult children',
                      'Prefer not to say', // Added option
                    ],
                    value: _childrenStatus,
                    onChanged: (newValue) {
                      setState(() {
                        _childrenStatus = newValue;
                      });
                    },
                    isDarkMode: isDarkMode,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Wants Children Switch (NEW FIELD)
                _buildThemedSwitchListTile(
                  title: 'Do you want children in the future?',
                  value: _wantsChildren,
                  onChanged: (bool value) {
                    setState(() {
                      _wantsChildren = value;
                    });
                  },
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Childhood Description Text Field
                _buildThemedTextField(
                  controller: _childhoodDescriptionController,
                  label: 'Describe your childhood environment or upbringing (Optional)',
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  maxLines: 3,
                ),
                SizedBox(height: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge), // Responsive spacing

                // Cultural Background Text Field
                _buildThemedTextField(
                  controller: _culturalBackgroundController,
                  label: 'Cultural background or traditions important to you (Optional)',
                  isDarkMode: isDarkMode,
                  isSmallScreen: isSmallScreen,
                  maxLines: 2,
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