// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/personality_and_self_reflection_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Ensure this path is correct
import 'dart:math' as math; // For random numbers in particle effects

class PersonalityAndSelfReflectionForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const PersonalityAndSelfReflectionForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<PersonalityAndSelfReflectionForm> createState() => _PersonalityAndSelfReflectionFormState();
}

class _PersonalityAndSelfReflectionFormState extends State<PersonalityAndSelfReflectionForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Text editing controllers
  late TextEditingController _selfDescriptionController;

  // Selected values for dropdowns
  String? _selectedPersonalityType;
  String? _selectedIntrovertExtrovertScale;
  String? _selectedEmotionalIntelligenceLevel;

  // Animation controller for subtle background effects
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _selfDescriptionController = TextEditingController(text: widget.userProfile.selfDescription ?? '');
    _selectedPersonalityType = widget.userProfile.personalityType;
    _selectedIntrovertExtrovertScale = widget.userProfile.introvertExtrovertScale;
    _selectedEmotionalIntelligenceLevel = widget.userProfile.emotionalIntelligenceLevel;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer

    // Add listener to update the parent profile immediately on change
    _selfDescriptionController.addListener(_updateUserProfile);
  }

  @override
  void dispose() {
    _selfDescriptionController.removeListener(_updateUserProfile);
    _selfDescriptionController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      selfDescription: _selfDescriptionController.text.trim().isNotEmpty ? _selfDescriptionController.text.trim() : null,
      personalityType: _selectedPersonalityType,
      introvertExtrovertScale: _selectedIntrovertExtrovertScale,
      emotionalIntelligenceLevel: _selectedEmotionalIntelligenceLevel,
      updatedAt: DateTime.now(), // Update timestamp on any change
    );
    widget.onUpdate(updatedProfile);
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive when swiping tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    final themeController = Provider.of<ThemeController>(context);
    final bool isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color primaryColor = AppConstants.primaryColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;
    final Color inputFillColor = primaryColor.withOpacity(0.05);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.3) : AppConstants.lightBorderColor.withOpacity(0.5);

    return Stack(
      children: [
        // Subtle animated background for cosmic feel
        AnimatedBuilder(
          animation: _backgroundAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter: _CosmicDustPainter(
                animationValue: _backgroundAnimationController.value,
                baseColor: primaryColor.withOpacity(0.1),
                accentColor: accentColor.withOpacity(0.05),
              ),
              child: Container(),
            );
          },
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Your Inner Cosmos', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Unveil your unique personality, how you interact with the world, and your emotional depth.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Self Description / About Me
              _buildTextField(
                controller: _selfDescriptionController,
                label: "About Me",
                hintText: DummyData.(selfDescriptionPrompts ?? []).isNotEmpty
                    ? DummyData.selfDescriptionPrompts[
                        (AppConstants.random.nextInt(DummyData.selfDescriptionPrompts.length))] // Random prompt as hint
                    : 'e.g., I’m an adventurous spirit who loves deep conversations and quiet evenings.',
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Personality Type
              _buildDropdownField<String>(
                label: "Personality Type (e.g., MBTI)",
                value: _selectedPersonalityType,
                items: DummyData.personalityTypeOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedPersonalityType = value;
                    _updateUserProfile();
                  });
                },
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Introvert/Extrovert Scale
              _buildDropdownField<String>(
                label: "Introvert/Extrovert Spectrum",
                value: _selectedIntrovertExtrovertScale,
                items: DummyData.introvertExtrovertOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedIntrovertExtrovertScale = value;
                    _updateUserProfile();
                  });
                },
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Emotional Intelligence Level
              _buildDropdownField<String>(
                label: "Emotional Intelligence Level",
                value: _selectedEmotionalIntelligenceLevel,
                items: DummyData.emotionalIntelligenceOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedEmotionalIntelligenceLevel = value;
                    _updateUserProfile();
                  });
                },
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingXXL), // Extra space at the bottom for scrolling
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets for consistent styling (enhanced for immersion) ---

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall, horizontal: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.3),
            AppConstants.accentColor.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.2),
            blurRadius: AppConstants.elevationMedium,
            spreadRadius: AppConstants.elevationExtraSmall,
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          shadows: [
            Shadow(
              offset: const Offset(2, 2),
              blurRadius: 5.0,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    required Color textColor,
    required Color surfaceColor,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color borderColor,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppConstants.fontSizeMedium,
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: const Offset(0.5, 0.5),
                blurRadius: 1.0,
                color: primaryColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor, fontSize: AppConstants.fontSizeBody),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: textColor.withOpacity(0.5), fontSize: AppConstants.fontSizeBody),
            filled: true,
            fillColor: inputFillColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingMedium,
              horizontal: AppConstants.paddingLarge,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
            ),
          ),
          cursorColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
    required Color textColor,
    required Color surfaceColor,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color borderColor,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppConstants.fontSizeMedium,
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: const Offset(0.5, 0.5),
                blurRadius: 1.0,
                color: primaryColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: AppConstants.elevationExtraSmall,
                spreadRadius: AppConstants.elevationExtraSmall,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              isExpanded: true,
              dropdownColor: surfaceColor.withOpacity(0.9),
              style: TextStyle(color: textColor, fontSize: AppConstants.fontSizeBody),
              icon: Icon(Icons.arrow_drop_down, color: accentColor),
              onChanged: onChanged,
              validator: validator,
              items: items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                errorStyle: TextStyle(color: AppConstants.errorColor, fontSize: AppConstants.fontSizeSmall),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for subtle cosmic dust/starfield background (reused)
class _CosmicDustPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color accentColor;
  final int numberOfParticles = 150;
  final double maxParticleSize = 2.5;
  final double minParticleSize = 0.5;

  static final List<List<double>> _particles = [];
  static final math.Random _random = math.Random();

  _CosmicDustPainter({
    required this.animationValue,
    required this.baseColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if ((_particles ?? []).isEmpty) {
      for (int i = 0; i < numberOfParticles; i++) {
        _particles.add([
          _random.nextDouble() * size?.width,
          _random.nextDouble() * size?.height,
          _random.nextDouble() * (maxParticleSize - minParticleSize) + minParticleSize,
          _random.nextDouble() * 0.6 + 0.4,
          _random.nextDouble() * 2 * math.pi,
        ]);
      }
    }

    final Paint particlePaint = Paint();
    for (final particle in _particles) {
      final double x = particle?[0];
      final double y = particle?[1];
      final double size = particle?[2];
      final double baseOpacity = particle?[3];
      final double initialPhase = particle?[4];

      final double twinkleFactor = (math.sin((animationValue * 2 * math.pi) + initialPhase) * 0.5 + 0.5);
      final double currentOpacity = (baseOpacity * twinkleFactor).clamp(0.0, 1.0);

      particlePaint.color = Color.lerp(baseColor, accentColor, twinkleFactor)!.withOpacity(currentOpacity);
      canvas.drawCircle(Offset(x, y), size * twinkleFactor, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicDustPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.baseColor != baseColor ||
           oldDelegate.accentColor != accentColor;
  }
}