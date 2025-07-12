// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/personal_and_contact_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart';
import 'dart:math' as math;

class PersonalAndContactForm extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const PersonalAndContactForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<PersonalAndContactForm> createState() => _PersonalAndContactFormState();
}

class _PersonalAndContactFormState extends State<PersonalAndContactForm>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  // Text editing controllers for various fields
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;

  // Selected values for dropdowns
  String? _selectedGender;
  String? _selectedPronouns;
  String? _selectedSexualOrientation;
  String? _selectedCountry;
  String? _selectedStateProvince;

  // For Date of Birth Picker
  DateTime? _selectedDateOfBirth;

  // Animation controller for subtle background effects
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userProfile.fullName);
    _phoneNumberController = TextEditingController(text: widget.userProfile.phoneNumber);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _addressController = TextEditingController(text: widget.userProfile.address);
    _cityController = TextEditingController(text: widget.userProfile.city);
    _zipCodeController = TextEditingController(text: widget.userProfile.zipCode);

    _selectedGender = widget.userProfile.gender;
    _selectedPronouns = widget.userProfile.pronouns;
    _selectedSexualOrientation = widget.userProfile.sexualOrientation;
    _selectedCountry = widget.userProfile.country;
    _selectedStateProvince = widget.userProfile.stateProvince;
    _selectedDateOfBirth = widget.userProfile.dateOfBirth;

    // Initialize and start background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Longer duration for subtle movement
    )..repeat(reverse: true); // Repeat back and forth for a gentle shimmer

    // Add listeners to update the parent profile immediately on change
    _fullNameController.addListener(_updateUserProfile);
    _phoneNumberController.addListener(_updateUserProfile);
    _emailController.addListener(_updateUserProfile);
    _addressController.addListener(_updateUserProfile);
    _cityController.addListener(_updateUserProfile);
    _zipCodeController.addListener(_updateUserProfile);
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_updateUserProfile);
    _phoneNumberController.removeListener(_updateUserProfile);
    _emailController.removeListener(_updateUserProfile);
    _addressController.removeListener(_updateUserProfile);
    _cityController.removeListener(_updateUserProfile);
    _zipCodeController.removeListener(_updateUserProfile);

    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _updateUserProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      fullName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
      phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      zipCode: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : null,
      gender: _selectedGender,
      pronouns: _selectedPronouns,
      sexualOrientation: _selectedSexualOrientation,
      country: _selectedCountry,
      stateProvince: _selectedStateProvince,
      dateOfBirth: _selectedDateOfBirth,
      updatedAt: DateTime.now(), // Update timestamp on any change
    );
    widget.onUpdate(updatedProfile);
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be at least 18 years old
      builder: (BuildContext context, Widget? child) {
        final theme = Provider.of<ThemeController>(context).currentTheme;
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppConstants.primaryColor,
              onPrimary: AppConstants.textColor,
              surface: theme.surfaceColor,
              onSurface: theme.textColor,
            ),
            dialogBackgroundColor: theme.backgroundColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.accentColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _updateUserProfile();
      });
    }
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
              _buildSectionTitle('Your Identity Beacon', isDarkMode),
              const SizedBox(height: AppConstants.spacingMedium),
              Text(
                "Let's get the essentials. Your basic information helps us create your unique identity within the cosmos.",
                style: AppConstants.subtitleTextStyle.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Full Name
              _buildTextField(
                controller: _fullNameController,
                label: "Full Name",
                hintText: 'John Doe',
                keyboardType: TextInputType.name,
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Date of Birth
              _buildDatePickerField(
                label: "Date of Birth",
                selectedDate: _selectedDateOfBirth,
                onTap: () => _selectDateOfBirth(context),
                textColor: textColor,
                surfaceColor: surfaceColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Gender
              _buildDropdownField<String>(
                label: "Gender Identity",
                value: _selectedGender,
                items: DummyData.genderOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
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

              // Pronouns
              _buildDropdownField<String>(
                label: "Preferred Pronouns",
                value: _selectedPronouns,
                items: DummyData.pronounOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedPronouns = value;
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

              // Sexual Orientation
              _buildDropdownField<String>(
                label: "Sexual Orientation",
                value: _selectedSexualOrientation,
                items: DummyData.sexualOrientationOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedSexualOrientation = value;
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
              const SizedBox(height: AppConstants.spacingXXL), // Extra space at the bottom
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

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingMedium,
              horizontal: AppConstants.paddingLarge,
            ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                  style: TextStyle(
                    color: selectedDate == null ? textColor.withOpacity(0.5) : textColor,
                    fontSize: AppConstants.fontSizeBody,
                  ),
                ),
                Icon(Icons.calendar_today, color: accentColor),
              ],
            ),
          ),
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
          _random.nextDouble() * 0.1 + 0.05, // movement speed factor
          _random.nextDouble() * 2 * math.pi, // movement direction angle
        ]);
      }
    }

    final Paint particlePaint = Paint();
    for (final particle in _particles) {
      // Apply subtle movement based on animationValue
      final double moveX = math.cos(particle?[6]) * particle?[5] * animationValue * size?.width * 0.01;
      final double moveY = math.sin(particle?[6]) * particle?[5] * animationValue * size?.height * 0.01;

      double x = (particle?[0] + moveX) % size?.width;
      if (x < 0) x += size?.width; // Wrap around
      double y = (particle?[1] + moveY) % size?.height;
      if (y < 0) y += size?.height; // Wrap around

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