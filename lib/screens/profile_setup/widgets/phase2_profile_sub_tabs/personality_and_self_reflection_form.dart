import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations

/// A detailed form for users to specify their personality traits and self-reflection.
/// This widget aims for an immersive UI/UX consistent with the app's cosmic theme,
/// utilizing various Flutter widgets, animations, and AppConstants for styling.
class PersonalityAndSelfReflectionForm extends StatefulWidget {
  const PersonalityAndSelfReflectionForm({super.key});

  @override
  State<PersonalityAndSelfReflectionForm> createState() => _PersonalityAndSelfReflectionFormState();
}

class _PersonalityAndSelfReflectionFormState extends State<PersonalityAndSelfReflectionForm> with TickerProviderStateMixin {
  // Controllers for text input fields
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _weaknessesController = TextEditingController();
  final TextEditingController _selfDescriptionController = TextEditingController();
  final TextEditingController _lifePhilosophyController = TextEditingController();

  // State variables for form selections
  String? _personalityType; // e.g., 'Introvert', 'Extrovert', 'Ambivert'
  String? _decisionMakingStyle; // e.g., 'Logical', 'Intuitive', 'Balanced'
  double _opennessToExperience = 0.5; // Slider value
  double _conscientiousness = 0.5; // Slider value
  double _extraversion = 0.5; // Slider value
  double _agreeableness = 0.5; // Slider value
  double _neuroticism = 0.5; // Slider value

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
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _selfDescriptionController.dispose();
    _lifePhilosophyController.dispose();
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

  /// Builds a themed slider for personality traits.
  Widget _buildThemedSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required bool isDarkMode,
    List<String> divisionsLabels = const ['Low', '', 'Medium', '', 'High'],
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color activeColor = AppConstants.secondaryColor;
    final Color inactiveColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);
    final Color thumbColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFamily: 'Inter',
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: inactiveColor,
            thumbColor: thumbColor,
            overlayColor: activeColor.withOpacity(0.2),
            valueIndicatorColor: activeColor,
            valueIndicatorTextStyle: TextStyle(
              color: AppConstants.textColor,
              fontSize: AppConstants.fontSizeSmall,
              fontFamily: 'Inter',
            ),
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: activeColor,
            inactiveTickMarkColor: inactiveColor,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 4, // 5 points: 0.0, 0.25, 0.5, 0.75, 1.0
            label: divisionsLabels[(value * 4).round()], // Show label for each division
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: divisionsLabels.map((label) => Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: AppConstants.fontSizeSmall,
              fontFamily: 'Inter',
            ),
          )).toList(),
        ),
      ],
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
                    'Personality & Self-Reflection',
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

              // Personality Type Dropdown
              _buildThemedDropdown(
                label: 'Which best describes your personality type?',
                items: const [
                  'Introvert',
                  'Extrovert',
                  'Ambivert',
                  'Highly Sensitive Person (HSP)',
                  'Thinker',
                  'Feeler',
                  'Observer',
                  'Challenger',
                ],
                value: _personalityType,
                onChanged: (newValue) {
                  setState(() {
                    _personalityType = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Decision Making Style Dropdown
              _buildThemedDropdown(
                label: 'How do you typically make decisions?',
                items: const [
                  'Logically and analytically',
                  'Intuitively and based on gut feeling',
                  'A balanced approach of logic and intuition',
                  'Consulting others',
                  'Spontaneously',
                ],
                value: _decisionMakingStyle,
                onChanged: (newValue) {
                  setState(() {
                    _decisionMakingStyle = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Big Five Personality Traits Sliders
              Text(
                'Rate yourself on the following personality traits:',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildThemedSlider(
                label: 'Openness to Experience (Curious, Imaginative)',
                value: _opennessToExperience,
                onChanged: (newValue) {
                  setState(() {
                    _opennessToExperience = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildThemedSlider(
                label: 'Conscientiousness (Organized, Disciplined)',
                value: _conscientiousness,
                onChanged: (newValue) {
                  setState(() {
                    _conscientiousness = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildThemedSlider(
                label: 'Extraversion (Outgoing, Energetic)',
                value: _extraversion,
                onChanged: (newValue) {
                  setState(() {
                    _extraversion = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildThemedSlider(
                label: 'Agreeableness (Compassionate, Cooperative)',
                value: _agreeableness,
                onChanged: (newValue) {
                  setState(() {
                    _agreeableness = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              _buildThemedSlider(
                label: 'Neuroticism (Sensitive, Anxious)',
                value: _neuroticism,
                onChanged: (newValue) {
                  setState(() {
                    _neuroticism = newValue;
                  });
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Strengths Text Field
              _buildThemedTextField(
                controller: _strengthsController,
                label: 'What are your greatest strengths?',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Weaknesses Text Field
              _buildThemedTextField(
                controller: _weaknessesController,
                label: 'What areas are you working to improve?',
                isDarkMode: isDarkMode,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Self-Description Text Field
              _buildThemedTextField(
                controller: _selfDescriptionController,
                label: 'In your own words, describe yourself.',
                isDarkMode: isDarkMode,
                maxLines: 4,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Life Philosophy Text Field
              _buildThemedTextField(
                controller: _lifePhilosophyController,
                label: 'What is your guiding philosophy in life?',
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
