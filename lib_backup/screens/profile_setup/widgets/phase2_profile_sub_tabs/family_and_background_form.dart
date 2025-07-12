// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/family_and_background_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Ensure this path is correct
import 'dart:math' as math; // For random numbers in particle effects

class FamilyAndBackgroundForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const FamilyAndBackgroundForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<FamilyAndBackgroundForm> createState() => _FamilyAndBackgroundFormState();
}

class _FamilyAndBackgroundFormState extends State<FamilyAndBackgroundForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Text editing controllers
  late TextEditingController _numberOfSiblingsController;
  late TextEditingController _siblingsDescriptionController;

  // Selected values for dropdowns/multi-selects
  String? _selectedCulturalBackground;
  List<String> _selectedFamilyValues = [];
  String? _selectedFamilyOrigin;

  // Animation controller for subtle background effects (e.g., twinkling stars, cosmic dust)
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _numberOfSiblingsController = TextEditingController(text: widget.userProfile.numberOfSiblings?.toString() ?? '');
    _siblingsDescriptionController = TextEditingController(text: widget.userProfile.siblingsDescription ?? '');
    _selectedCulturalBackground = widget.userProfile.culturalBackground;
    _selectedFamilyValues = List.from(widget.userProfile.familyValues ?? []);
    _selectedFamilyOrigin = widget.userProfile.familyOrigin;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer

    // Add listeners to update the parent profile immediately on change
    _numberOfSiblingsController.addListener(_updateUserProfile);
    _siblingsDescriptionController.addListener(_updateUserProfile);
  }

  @override
  void dispose() {
    _numberOfSiblingsController.removeListener(_updateUserProfile);
    _siblingsDescriptionController.removeListener(_updateUserProfile);
    _numberOfSiblingsController.dispose();
    _siblingsDescriptionController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      numberOfSiblings: int.tryParse(_numberOfSiblingsController.text),
      siblingsDescription: _siblingsDescriptionController.text.trim().isNotEmpty ? _siblingsDescriptionController.text.trim() : null,
      culturalBackground: _selectedCulturalBackground,
      familyValues: (_selectedFamilyValues ?? []).isEmpty ? null : _selectedFamilyValues,
      familyOrigin: _selectedFamilyOrigin,
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
              _buildSectionTitle('Your Roots and Values', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Share a bit about your family background, cultural heritage, and the values that shape you.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Cultural Background
              _buildDropdownField<String>(
                label: "Cultural Background",
                value: _selectedCulturalBackground,
                items: DummyData.culturalBackgroundOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedCulturalBackground = value;
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

              // Family Origin
              _buildDropdownField<String>(
                label: "Family Origin",
                value: _selectedFamilyOrigin,
                items: DummyData.familyOriginOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedFamilyOrigin = value;
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

              // Number of Siblings
              _buildTextField(
                controller: _numberOfSiblingsController,
                label: "Number of Siblings (Optional)",
                hintText: 'e.g., 2',
                keyboardType: TextInputType.number,
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Siblings Description
              _buildTextField(
                controller: _siblingsDescriptionController,
                label: "Tell us about your siblings (Optional)",
                hintText: 'e.g., I have an older brother and a younger sister, we are very close.',
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Family Values Multi-select
              _buildMultiSelectChipField<String>(
                label: "Key Family Values",
                options: DummyData.familyValuesOptions,
                selectedOptions: _selectedFamilyValues,
                onSelected: (item) => _toggleMultiSelectItem(_selectedFamilyValues, item),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
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
              dropdownColor: surfaceColor.withOpacity(0.9), // Slightly transparent dropdown
              style: TextStyle(color: textColor, fontSize: AppConstants.fontSizeBody),
              icon: Icon(Icons.arrow_drop_down, color: accentColor), // Accent colored dropdown icon
              onChanged: onChanged,
              validator: validator,
              items: items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              decoration: InputDecoration(
                border: InputBorder.none, // Remove inner border
                contentPadding: EdgeInsets.zero, // Remove inner padding
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
          spacing: AppConstants.spacingSmall, // Horizontal space between chips
          runSpacing: AppConstants.spacingSmall, // Vertical space between lines of chips
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

// Custom Painter for subtle cosmic dust/starfield background
class _CosmicDustPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color accentColor;
  final int numberOfParticles = 150; // Increased particles for denser effect
  final double maxParticleSize = 2.5; // Max size of a particle
  final double minParticleSize = 0.5; // Min size of a particle

  // Store particle properties once to avoid recalculation
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
      // Initialize particles once
      for (int i = 0; i < numberOfParticles; i++) {
        _particles.add([
          _random.nextDouble() * size?.width, // x position
          _random.nextDouble() * size?.height, // y position
          _random.nextDouble() * (maxParticleSize - minParticleSize) + minParticleSize, // size
          _random.nextDouble() * 0.6 + 0.4, // base opacity (0.4 to 1.0)
          _random.nextDouble() * 2 * math.pi, // initial phase for twinkle
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

      // Subtle twinkling effect using sine wave
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