import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'dart:math' as math; // For subtle animations
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

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
  String? _astrologicalSign; // New field
  String? _attachmentStyle; // New field
  String? _communicationStyle; // New field
  bool _mentalHealthDisclosures = false; // New field: for mental health disclosures

  // Big Five Personality Traits (Sliders)
  double _opennessToExperience = 0.5; // Range 0.0 - 1.0
  double _conscientiousness = 0.5; // Range 0.0 - 1.0
  double _extraversion = 0.5; // Range 0.0 - 1.0
  double _agreeableness = 0.5; // Range 0.0 - 1.0
  double _neuroticism = 0.5; // Range 0.0 - 1.0

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
            borderSide: BorderSide(color: activeColor, width: 2.0),
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
            borderSide: BorderSide(color: activeColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingMedium),
        ),
        cursorColor: activeColor,
      ),
    );
  }

  /// Builds a themed slider for personality traits.
  Widget _buildThemedSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required bool isDarkMode,
  }) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color inactiveColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Inter',
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: inactiveColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.2),
            valueIndicatorColor: activeColor,
            valueIndicatorTextStyle: TextStyle(color: isDarkMode ? Colors.black : Colors.white, fontFamily: 'Inter'),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 10, // 0.1 increments
            label: (value * 10).round().toString(), // Show 0-10 scale
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
      ],
    );
  }

  /// Builds a themed switch list tile.
  Widget _buildThemedSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
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
          fontSize: AppConstants.fontSizeMedium,
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
          padding: const EdgeInsets.all(AppConstants.paddingMedium), // Consistent padding
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
            padding: const EdgeInsets.all(AppConstants.paddingLarge), // Inner padding for content
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
                            'Your Personality & Self-Reflection',
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
                    ),
                    // App Name and Icon for branding
                    Row(
                      children: [
                        Text(
                          'Blind AI Dating',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        SvgPicture.asset(
                          'assets/svg/DrawKit Vector Illustration Love & Dating (8).svg', // Example SVG for Personality
                          height: 40,
                          semanticsLabel: 'Personality Icon',
                          colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Dive deeper into your personality and how you reflect on yourself. This helps us understand your unique character and find truly compatible minds.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.8)),
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Personality Type Dropdown
                _buildThemedDropdown(
                  label: 'What best describes your personality type?',
                  items: const [
                    'Introvert',
                    'Extrovert',
                    'Ambivert',
                    'Prefer not to say', // Added option
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

                // Decision-Making Style Dropdown
                _buildThemedDropdown(
                  label: 'What is your decision-making style?',
                  items: const [
                    'Logical/Rational',
                    'Intuitive/Emotional',
                    'Balanced (mix of both)',
                    'Consultative (seek advice)',
                    'Prefer not to say', // Added option
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

                // Astrological Sign Dropdown (NEW)
                _buildThemedDropdown(
                  label: 'Astrological Sign (Optional)',
                  items: const [
                    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
                    'Prefer not to say',
                  ],
                  value: _astrologicalSign,
                  onChanged: (newValue) {
                    setState(() {
                      _astrologicalSign = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Attachment Style Dropdown (NEW)
                _buildThemedDropdown(
                  label: 'Attachment Style (Optional)',
                  items: const [
                    'Secure', 'Anxious-Preoccupied', 'Dismissive-Avoidant', 'Fearful-Avoidant',
                    'Still learning', 'Prefer not to say',
                  ],
                  value: _attachmentStyle,
                  onChanged: (newValue) {
                    setState(() {
                      _attachmentStyle = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Communication Style Dropdown (NEW)
                _buildThemedDropdown(
                  label: 'Communication Style (Optional)',
                  items: const [
                    'Direct & Assertive', 'Indirect & Subtle', 'Passive', 'Aggressive',
                    'Open & Expressive', 'Reserved', 'Prefer not to say',
                  ],
                  value: _communicationStyle,
                  onChanged: (newValue) {
                    setState(() {
                      _communicationStyle = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Mental Health Disclosures Switch (NEW)
                _buildThemedSwitchListTile(
                  title: 'Open to discussing mental health disclosures?',
                  value: _mentalHealthDisclosures,
                  onChanged: (bool value) {
                    setState(() {
                      _mentalHealthDisclosures = value;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppConstants.spacingLarge),

                // Sliders for Big Five Personality Traits
                Text(
                  'Rate yourself on these personality dimensions (1-10):',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                _buildThemedSlider(
                  label: 'Openness to Experience (Curious vs. Cautious)',
                  value: _opennessToExperience,
                  onChanged: (newValue) {
                    setState(() {
                      _opennessToExperience = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildThemedSlider(
                  label: 'Conscientiousness (Organized vs. Easy-going)',
                  value: _conscientiousness,
                  onChanged: (newValue) {
                    setState(() {
                      _conscientiousness = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildThemedSlider(
                  label: 'Extraversion (Outgoing vs. Solitary)',
                  value: _extraversion,
                  onChanged: (newValue) {
                    setState(() {
                      _extraversion = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildThemedSlider(
                  label: 'Agreeableness (Friendly vs. Challenging)',
                  value: _agreeableness,
                  onChanged: (newValue) {
                    setState(() {
                      _agreeableness = newValue;
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildThemedSlider(
                  label: 'Neuroticism (Sensitive vs. Confident)',
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
                  label: 'What are your greatest strengths? (Optional)',
                  isDarkMode: isDarkMode,
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Weaknesses Text Field
                _buildThemedTextField(
                  controller: _weaknessesController,
                  label: 'What are areas you\'re working to improve? (Optional)',
                  isDarkMode: isDarkMode,
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Self-Description Text Field
                _buildThemedTextField(
                  controller: _selfDescriptionController,
                  label: 'Describe yourself in three words (Optional)',
                  isDarkMode: isDarkMode,
                  maxLines: 1,
                ),
                const SizedBox(height: AppConstants.spacingMedium),

                // Life Philosophy Text Field
                _buildThemedTextField(
                  controller: _lifePhilosophyController,
                  label: 'What\'s your guiding life philosophy or motto? (Optional)',
                  isDarkMode: isDarkMode,
                  maxLines: 2,
                ),
                const SizedBox(height: AppConstants.paddingSmall), // Final spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
