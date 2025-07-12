// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/dating_and_relationship_goals_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart';
import 'dart:math' as math;

class DatingAndRelationshipGoalsForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const DatingAndRelationshipGoalsForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<DatingAndRelationshipGoalsForm> createState() => _DatingAndRelationshipGoalsFormState();
}

class _DatingAndRelationshipGoalsFormState extends State<DatingAndRelationshipGoalsForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Selected values for dropdowns/multi-selects
  List<String> _selectedLookingFor = []; // Multi-select
  String? _selectedRelationshipType;
  List<String> _selectedIdealPartnerQualities = []; // Multi-select
  String? _selectedConflictResolutionStyle;
  String? _selectedLoveLanguage;
  String? _selectedCommunicationPreference;
  String? _selectedDealBreaker; // Single select text input

  // Animation controller for subtle background effects
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _selectedLookingFor = List.from(widget.userProfile.lookingFor ?? []);
    _selectedRelationshipType = widget.userProfile.relationshipType;
    _selectedIdealPartnerQualities = List.from(widget.userProfile.idealPartnerQualities ?? []);
    _selectedConflictResolutionStyle = widget.userProfile.conflictResolutionStyle;
    _selectedLoveLanguage = widget.userProfile.loveLanguage;
    _selectedCommunicationPreference = widget.userProfile.communicationPreference;
    _selectedDealBreaker = widget.userProfile.dealBreaker;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      lookingFor: (_selectedLookingFor ?? []).isEmpty ? null : _selectedLookingFor,
      relationshipType: _selectedRelationshipType,
      idealPartnerQualities: (_selectedIdealPartnerQualities ?? []).isEmpty ? null : _selectedIdealPartnerQualities,
      conflictResolutionStyle: _selectedConflictResolutionStyle,
      loveLanguage: _selectedLoveLanguage,
      communicationPreference: _selectedCommunicationPreference,
      dealBreaker: _selectedDealBreaker,
      updatedAt: DateTime.now(), // Update timestamp on any change
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
              _buildSectionTitle('Charting Your Love Orbit', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Define your cosmic compatibility by outlining your dating intentions and what you seek in a stellar partner.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Looking For (Multi-select)
              _buildMultiSelectChipField<String>(
                label: "What are you looking for?",
                options: DummyData.lookingForOptions,
                selectedOptions: _selectedLookingFor,
                onSelected: (item) => _toggleMultiSelectItem(_selectedLookingFor, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Relationship Type
              _buildDropdownField<String>(
                label: "Desired Relationship Type",
                value: _selectedRelationshipType,
                items: DummyData.relationshipTypeOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedRelationshipType = value;
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

              // Ideal Partner Qualities (Multi-select)
              _buildMultiSelectChipField<String>(
                label: "Ideal Partner Qualities",
                options: DummyData.idealPartnerQualitiesOptions,
                selectedOptions: _selectedIdealPartnerQualities,
                onSelected: (item) => _toggleMultiSelectItem(_selectedIdealPartnerQualities, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Conflict Resolution Style
              _buildDropdownField<String>(
                label: "Conflict Resolution Style",
                value: _selectedConflictResolutionStyle,
                items: DummyData.conflictResolutionStyleOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedConflictResolutionStyle = value;
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

              // Love Language
              _buildDropdownField<String>(
                label: "Your Love Language",
                value: _selectedLoveLanguage,
                items: DummyData.loveLanguageOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedLoveLanguage = value;
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

              // Communication Preference
              _buildDropdownField<String>(
                label: "Communication Preference",
                value: _selectedCommunicationPreference,
                items: DummyData.communicationPreferenceOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedCommunicationPreference = value;
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

              // Deal Breaker (Single select with text input style)
              _buildDropdownField<String>(
                label: "Your Top Deal Breaker",
                value: _selectedDealBreaker,
                items: DummyData.dealBreakerOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedDealBreaker = value;
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

  // --- Reused and Enhanced Helper Widgets ---

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
  final int numberOfParticles = 200;
  final double maxParticleSize = 3.0;
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