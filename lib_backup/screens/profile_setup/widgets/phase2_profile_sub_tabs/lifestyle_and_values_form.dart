// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/lifestyle_and_values_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart';
import 'dart:math' as math;

class LifestyleAndValuesForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const LifestyleAndValuesForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<LifestyleAndValuesForm> createState() => _LifestyleAndValuesFormState();
}

class _LifestyleAndValuesFormState extends State<LifestyleAndValuesForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Selected values for dropdowns/multi-selects
  String? _selectedDietaryPreference;
  String? _selectedSmokingHabit;
  String? _selectedDrinkingHabit;
  String? _selectedExerciseFrequency;
  List<String> _selectedHobbiesInterests = [];
  List<String> _selectedCoreValues = [];
  List<String> _selectedCommunicationStyles = [];
  List<String> _selectedPets = [];
  String? _selectedSocialMediaActivity;
  String? _selectedTravelFrequency;

  // Animation controller for subtle background effects
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _selectedDietaryPreference = widget.userProfile.dietaryPreference;
    _selectedSmokingHabit = widget.userProfile.smokingHabit;
    _selectedDrinkingHabit = widget.userProfile.drinkingHabit;
    _selectedExerciseFrequency = widget.userProfile.exerciseFrequency;
    _selectedHobbiesInterests = List.from(widget.userProfile.hobbiesInterests ?? []);
    _selectedCoreValues = List.from(widget.userProfile.coreValues ?? []);
    _selectedCommunicationStyles = List.from(widget.userProfile.communicationStyles ?? []);
    _selectedPets = List.from(widget.userProfile.pets ?? []);
    _selectedSocialMediaActivity = widget.userProfile.socialMediaActivity;
    _selectedTravelFrequency = widget.userProfile.travelFrequency;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      dietaryPreference: _selectedDietaryPreference,
      smokingHabit: _selectedSmokingHabit,
      drinkingHabit: _selectedDrinkingHabit,
      exerciseFrequency: _selectedExerciseFrequency,
      hobbiesInterests: (_selectedHobbiesInterests ?? []).isEmpty ? null : _selectedHobbiesInterests,
      coreValues: (_selectedCoreValues ?? []).isEmpty ? null : _selectedCoreValues,
      communicationStyles: (_selectedCommunicationStyles ?? []).isEmpty ? null : _selectedCommunicationStyles,
      pets: (_selectedPets ?? []).isEmpty ? null : _selectedPets,
      socialMediaActivity: _selectedSocialMediaActivity,
      travelFrequency: _selectedTravelFrequency,
      updatedAt: DateTime.now(),
    );
    widget.onUpdate(updatedProfile);
  }

  // Helper for adding/removing items from a multi-select list
  void _toggleMultiSelectItem(List<String> currentList, String item) {
    setState(() {
      if (currentList.contains(item)) {
        currentList.remove(item);
      } else {
        currentList.add(item);
      }
      _updateUserProfile(); // Propagate change immediately
    });
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
              _buildSectionTitle('Your Lifestyle Galaxy', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Illuminate your daily habits, passions, and core beliefs that light up your universe.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Dietary Preference
              _buildDropdownField<String>(
                label: "Dietary Preference",
                value: _selectedDietaryPreference,
                items: DummyData.dietaryPreferenceOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedDietaryPreference = value;
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

              // Smoking Habit
              _buildDropdownField<String>(
                label: "Smoking Habits",
                value: _selectedSmokingHabit,
                items: DummyData.smokingHabitOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedSmokingHabit = value;
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

              // Drinking Habit
              _buildDropdownField<String>(
                label: "Drinking Habits",
                value: _selectedDrinkingHabit,
                items: DummyData.drinkingHabitOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedDrinkingHabit = value;
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

              // Exercise Frequency
              _buildDropdownField<String>(
                label: "Exercise Frequency",
                value: _selectedExerciseFrequency,
                items: DummyData.exerciseFrequencyOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedExerciseFrequency = value;
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

              // Hobbies & Interests Multi-select
              _buildMultiSelectChipField<String>(
                label: "Hobbies & Interests",
                options: DummyData.hobbiesInterestsOptions,
                selectedOptions: _selectedHobbiesInterests,
                onSelected: (item) => _toggleMultiSelectItem(_selectedHobbiesInterests, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Core Values Multi-select
              _buildMultiSelectChipField<String>(
                label: "Core Values",
                options: DummyData.coreValuesOptions,
                selectedOptions: _selectedCoreValues,
                onSelected: (item) => _toggleMultiSelectItem(_selectedCoreValues, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Communication Styles Multi-select
              _buildMultiSelectChipField<String>(
                label: "Communication Styles",
                options: DummyData.communicationStyleOptions,
                selectedOptions: _selectedCommunicationStyles,
                onSelected: (item) => _toggleMultiSelectItem(_selectedCommunicationStyles, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Pets Multi-select
              _buildMultiSelectChipField<String>(
                label: "Pets",
                options: DummyData.petOptions,
                selectedOptions: _selectedPets,
                onSelected: (item) => _toggleMultiSelectItem(_selectedPets, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Social Media Activity
              _buildDropdownField<String>(
                label: "Social Media Activity",
                value: _selectedSocialMediaActivity,
                items: DummyData.socialMediaActivityOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedSocialMediaActivity = value;
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

              // Travel Frequency
              _buildDropdownField<String>(
                label: "Travel Frequency",
                value: _selectedTravelFrequency,
                items: DummyData.travelFrequencyOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedTravelFrequency = value;
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
              const SizedBox(height: AppConstants.spacingXXL),
            ],
          ),
        ),
      ],
    );
  }

  // --- Reused and Enhanced Helper Widgets from previous forms ---

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

  Widget _buildMultiSelectChipField<T>({
    required String label,
    required List<T> options,
    required List<T> selectedOptions,
    required ValueChanged<T> onSelected,
    required Color textColor,
    required Color surfaceColor,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
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
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: (options ?? []).map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [accentColor.withOpacity(0.8), primaryColor.withOpacity(0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : inputFillColor,
                  border: Border.all(
                    color: isSelected ? accentColor : textColor.withOpacity(0.2),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: AppConstants.elevationMedium,
                            spreadRadius: AppConstants.elevationExtraSmall,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppConstants.fontSizeBody,
                      color: isSelected ? AppConstants.textHighEmphasis : textColor.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Custom Painter for subtle cosmic dust/starfield background (reused and improved)
class _CosmicDustPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color accentColor;
  final int numberOfParticles = 200; // Increased particles for denser effect
  final double maxParticleSize = 3.0; // Max size of a particle
  final double minParticleSize = 0.5; // Min size of a particle

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
          _random.nextDouble() * 0.1 + 0.05,
          _random.nextDouble() * 2 * math.pi,
        ]);
      }
    }

    final Paint particlePaint = Paint();
    for (final particle in _particles) {
      final double moveX = math.cos(particle?[6]) * particle?[5] * animationValue * size?.width * 0.01;
      final double moveY = math.sin(particle?[6]) * particle?[5] * animationValue * size?.height * 0.01;

      double x = (particle?[0] + moveX) % size?.width;
      if (x < 0) x += size?.width;
      double y = (particle?[1] + moveY) % size?.height;
      if (y < 0) y += size?.height;

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