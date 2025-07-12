// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/physical_attributes_and_health_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart';
import 'dart:math' as math;

class PhysicalAttributesAndHealthForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const PhysicalAttributesAndHealthForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<PhysicalAttributesAndHealthForm> createState() => _PhysicalAttributesAndHealthFormState();
}

class _PhysicalAttributesAndHealthFormState extends State<PhysicalAttributesAndHealthForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Text editing controllers
  late TextEditingController _heightControllerFeet;
  late TextEditingController _heightControllerInches;
  late TextEditingController _weightController;

  // Selected values for dropdowns/multi-selects
  String? _selectedBodyType;
  String? _selectedEthnicity;
  String? _selectedHairType;
  String? _selectedEyeColor;
  String? _selectedHealthStatus;
  List<String> _selectedDisabilities = []; // Multi-select
  String? _selectedVaccinationStatus;

  // Animation controller for subtle background effects
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data or empty
    final double? heightInInches = widget.userProfile?.heightCm != null
        ? widget.userProfile?.heightCm! / 2.54 // Convert cm to inches
        : null;
    _heightControllerFeet = TextEditingController(text: heightInInches != null ? (heightInInches ~/ 12).toString() : '');
    _heightControllerInches = TextEditingController(text: heightInInches != null ? (heightInInches % 12).round().toString() : '');
    _weightController = TextEditingController(text: widget.userProfile.weightKg != null ? widget.userProfile.weightKg!.toString() : '');

    _selectedBodyType = widget.userProfile.bodyType;
    _selectedEthnicity = widget.userProfile.ethnicity;
    _selectedHairType = widget.userProfile.hairType;
    _selectedEyeColor = widget.userProfile.eyeColor;
    _selectedHealthStatus = widget.userProfile.healthStatus;
    _selectedDisabilities = List.from(widget.userProfile.disabilities ?? []);
    _selectedVaccinationStatus = widget.userProfile.vaccinationStatus;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer

    // Add listeners to update the parent profile immediately on change
    _heightControllerFeet.addListener(_updateUserProfile);
    _heightControllerInches.addListener(_updateUserProfile);
    _weightController.addListener(_updateUserProfile);
  }

  @override
  void dispose() {
    _heightControllerFeet.removeListener(_updateUserProfile);
    _heightControllerInches.removeListener(_updateUserProfile);
    _weightController.removeListener(_updateUserProfile);

    _heightControllerFeet.dispose();
    _heightControllerInches.dispose();
    _weightController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    // Calculate height in cm
    double? heightCm;
    final int? feet = int.tryParse(_heightControllerFeet.text);
    final int? inches = int.tryParse(_heightControllerInches.text);

    if (feet != null || inches != null) {
      final double totalInches = (feet ?? 0) * 12.0 + (inches ?? 0);
      if (totalInches > 0) {
        heightCm = totalInches * 2.54;
      }
    }

    final updatedProfile = widget.userProfile.copyWith(
      heightCm: heightCm,
      weightKg: double.tryParse(_weightController.text),
      bodyType: _selectedBodyType,
      ethnicity: _selectedEthnicity,
      hairType: _selectedHairType,
      eyeColor: _selectedEyeColor,
      healthStatus: _selectedHealthStatus,
      disabilities: (_selectedDisabilities ?? []).isEmpty ? null : _selectedDisabilities,
      vaccinationStatus: _selectedVaccinationStatus,
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
              _buildSectionTitle('Your Physical Blueprint', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Share insights into your physical form and overall well-being, helping us find compatible cosmic connections.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Height
              _buildHeightInput(
                label: "Height",
                feetController: _heightControllerFeet,
                inchesController: _heightControllerInches,
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Weight
              _buildTextField(
                controller: _weightController,
                label: "Weight (kg)",
                hintText: 'e.g., 70',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Body Type
              _buildDropdownField<String>(
                label: "Body Type",
                value: _selectedBodyType,
                items: DummyData.bodyTypeOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedBodyType = value;
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

              // Ethnicity
              _buildDropdownField<String>(
                label: "Ethnicity",
                value: _selectedEthnicity,
                items: DummyData.ethnicityOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedEthnicity = value;
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

              // Hair Type
              _buildDropdownField<String>(
                label: "Hair Type",
                value: _selectedHairType,
                items: DummyData.hairTypeOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedHairType = value;
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

              // Eye Color
              _buildDropdownField<String>(
                label: "Eye Color",
                value: _selectedEyeColor,
                items: DummyData.eyeColorOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedEyeColor = value;
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

              // Health Status
              _buildDropdownField<String>(
                label: "General Health Status",
                value: _selectedHealthStatus,
                items: DummyData.healthStatusOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedHealthStatus = value;
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

              // Disabilities Multi-select
              _buildMultiSelectChipField<String>(
                label: "Disabilities / Accessibility Needs (Optional)",
                options: DummyData.disabilityOptions,
                selectedOptions: _selectedDisabilities,
                onSelected: (item) => _toggleMultiSelectItem(_selectedDisabilities, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Vaccination Status
              _buildDropdownField<String>(
                label: "Vaccination Status",
                value: _selectedVaccinationStatus,
                items: DummyData.vaccinationStatusOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedVaccinationStatus = value;
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

  Widget _buildHeightInput({
    required String label,
    required TextEditingController feetController,
    required TextEditingController inchesController,
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
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: feetController,
                label: 'Feet',
                hintText: 'e.g., 5',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: _buildTextField(
                controller: inchesController,
                label: 'Inches',
                hintText: 'e.g., 8',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
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