import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations

/// A detailed form for users to specify their dating intentions and relationship goals.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class DatingAndRelationshipGoalsForm extends StatefulWidget {
  const DatingAndRelationshipGoalsForm({super.key});

  @override
  State<DatingAndRelationshipGoalsForm> createState() => _DatingAndRelationshipGoalsFormState();
}

class _DatingAndRelationshipGoalsFormState extends State<DatingAndRelationshipGoalsForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _idealPartnerQualitiesController = TextEditingController();
  final TextEditingController _futureAspirationsController = TextEditingController();

  // State variables for form selections
  String? _datingIntention;
  final List<String> _relationshipTypes = [];
  final List<String> _communicationStyles = [];

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
    _idealPartnerQualitiesController.dispose();
    _futureAspirationsController.dispose();
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
    final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
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
                    'Your Dating & Relationship Goals',
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

              // Dating Intention Dropdown
              _buildThemedDropdown(
                label: 'What are you looking for?',
                items: const [
                  'Long-term relationship',
                  'Casual dating',
                  'Friendship/Networking',
                  'Marriage',
                  'Something casual, open to long-term',
                  'Don\'t know yet',
                ],
                value: _datingIntention,
                onChanged: (newValue) {
                  setState(() {
                    _datingIntention = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Relationship Types Checkboxes
              Text(
                'What kind of relationship are you open to?',
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
                    title: 'Monogamous',
                    value: _relationshipTypes.contains('Monogamous'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _relationshipTypes.add('Monogamous');
                        } else {
                          _relationshipTypes.remove('Monogamous');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Polyamorous',
                    value: _relationshipTypes.contains('Polyamorous'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _relationshipTypes.add('Polyamorous');
                        } else {
                          _relationshipTypes.remove('Polyamorous');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Open Relationship',
                    value: _relationshipTypes.contains('Open Relationship'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _relationshipTypes.add('Open Relationship');
                        } else {
                          _relationshipTypes.remove('Open Relationship');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Friends with Benefits (FWB)',
                    value: _relationshipTypes.contains('Friends with Benefits (FWB)'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _relationshipTypes.add('Friends with Benefits (FWB)');
                        } else {
                          _relationshipTypes.remove('Friends with Benefits (FWB)');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Ideal Partner Qualities Text Field
              _buildThemedTextField(
                controller: _idealPartnerQualitiesController,
                label: 'Describe your ideal partner\'s qualities (e.g., values, personality, interests)',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Future Aspirations Text Field
              _buildThemedTextField(
                controller: _futureAspirationsController,
                label: 'What are your long-term aspirations in a relationship?',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Communication Styles Checkboxes
              Text(
                'How do you prefer to communicate in a relationship?',
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
                    title: 'Direct & Honest',
                    value: _communicationStyles.contains('Direct & Honest'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _communicationStyles.add('Direct & Honest');
                        } else {
                          _communicationStyles.remove('Direct & Honest');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Supportive & Empathetic',
                    value: _communicationStyles.contains('Supportive & Empathetic'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _communicationStyles.add('Supportive & Empathetic');
                        } else {
                          _communicationStyles.remove('Supportive & Empathetic');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Playful & Humorous',
                    value: _communicationStyles.contains('Playful & Humorous'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _communicationStyles.add('Playful & Humorous');
                        } else {
                          _communicationStyles.remove('Playful & Humorous');
                        }
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemedCheckboxListTile(
                    title: 'Reserved & Thoughtful',
                    value: _communicationStyles.contains('Reserved & Thoughtful'),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _communicationStyles.add('Reserved & Thoughtful');
                        } else {
                          _communicationStyles.remove('Reserved & Thoughtful');
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
