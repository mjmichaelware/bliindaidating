// lib/screens/profile_setup/widgets/phase2_profile_sub_tabs/education_and_career_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // For dummy options

class EducationAndCareerForm extends StatefulWidget {
  final UserProfile userProfile;
  final ValueChanged<UserProfile> onUpdate;

  const EducationAndCareerForm({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<EducationAndCareerForm> createState() => _EducationAndCareerFormState();
}

class _EducationAndCareerFormState extends State<EducationAndCareerForm> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  late TextEditingController _currentJobTitleController;
  late TextEditingController _companyNameController;
  late TextEditingController _currentSalaryController;
  late TextEditingController _schoolNameController;
  late TextEditingController _majorController;
  late TextEditingController _graduationYearController;
  late TextEditingController _careerAspirationsController;
  late TextEditingController _lifeGoalsController;

  // Dropdown selections
  String? _selectedEducationLevel;
  String? _selectedIndustry;
  String? _selectedEmploymentStatus;

  @override
  void initState() {
    super.initState();
    _currentJobTitleController = TextEditingController(text: widget.userProfile.currentJobTitle ?? '');
    _companyNameController = TextEditingController(text: widget.userProfile.companyName ?? '');
    _currentSalaryController = TextEditingController(text: widget.userProfile.currentSalary ?? '');
    _schoolNameController = TextEditingController(text: widget.userProfile.schoolName ?? '');
    _majorController = TextEditingController(text: widget.userProfile.major ?? '');
    _graduationYearController = TextEditingController(text: widget.userProfile.graduationYear?.toString() ?? '');
    _careerAspirationsController = TextEditingController(text: widget.userProfile.careerAspirations ?? '');
    _lifeGoalsController = TextEditingController(text: widget.userProfile.lifeGoals ?? '');

    _selectedEducationLevel = widget.userProfile.educationLevel;
    _selectedIndustry = widget.userProfile.industry;
    _selectedEmploymentStatus = widget.userProfile.employmentStatus;

    // Add listeners to update parent profile immediately on change
    _currentJobTitleController.addListener(_onUpdate);
    _companyNameController.addListener(_onUpdate);
    _currentSalaryController.addListener(_onUpdate);
    _schoolNameController.addListener(_onUpdate);
    _majorController.addListener(_onUpdate);
    _graduationYearController.addListener(_onUpdate);
    _careerAspirationsController.addListener(_onUpdate);
    _lifeGoalsController.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _currentJobTitleController.removeListener(_onUpdate);
    _companyNameController.removeListener(_onUpdate);
    _currentSalaryController.removeListener(_onUpdate);
    _schoolNameController.removeListener(_onUpdate);
    _majorController.removeListener(_onUpdate);
    _graduationYearController.removeListener(_onUpdate);
    _careerAspirationsController.removeListener(_onUpdate);
    _lifeGoalsController.removeListener(_onUpdate);

    _currentJobTitleController.dispose();
    _companyNameController.dispose();
    _currentSalaryController.dispose();
    _schoolNameController.dispose();
    _majorController.dispose();
    _graduationYearController.dispose();
    _careerAspirationsController.dispose();
    _lifeGoalsController.dispose();
    super.dispose();
  }

  // Method to update the parent UserProfile model via callback
  void _onUpdate() {
    final updatedProfile = widget.userProfile.copyWith(
      currentJobTitle: _currentJobTitleController.text.trim().isNotEmpty ? _currentJobTitleController.text.trim() : null,
      companyName: _companyNameController.text.trim().isNotEmpty ? _companyNameController.text.trim() : null,
      currentSalary: _currentSalaryController.text.trim().isNotEmpty ? _currentSalaryController.text.trim() : null,
      schoolName: _schoolNameController.text.trim().isNotEmpty ? _schoolNameController.text.trim() : null,
      major: _majorController.text.trim().isNotEmpty ? _majorController.text.trim() : null,
      graduationYear: int.tryParse(_graduationYearController.text.trim()),
      careerAspirations: _careerAspirationsController.text.trim().isNotEmpty ? _careerAspirationsController.text.trim() : null,
      lifeGoals: _lifeGoalsController.text.trim().isNotEmpty ? _lifeGoalsController.text.trim() : null,
      educationLevel: _selectedEducationLevel,
      industry: _selectedIndustry,
      employmentStatus: _selectedEmploymentStatus,
      updatedAt: DateTime.now(), // Update timestamp on any change
    );
    widget.onUpdate(updatedProfile);
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive when swiping tabs

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final themeController = Provider.of<ThemeController>(context);
    final bool isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color primaryColor = AppConstants.primaryColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;
    final Color inputFillColor = primaryColor.withOpacity(0.05);
    final Color borderColor = isDarkMode ? AppConstants.borderColor.withOpacity(0.3) : AppConstants.lightBorderColor.withOpacity(0.5);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingMedium,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Education & Career', isDarkMode),
            const SizedBox(height: AppConstants.spacingLarge),

            // Education Level Dropdown
            _buildDropdownField<String>(
              label: 'Highest Education Level',
              value: _selectedEducationLevel,
              items: DummyData.educationLevelOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedEducationLevel = newValue;
                  _onUpdate();
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

            // School Name Field
            _buildTextField(
              controller: _schoolNameController,
              label: 'School/University Name',
              hintText: 'e.g., Starfleet Academy',
              keyboardType: TextInputType.text,
              textColor: textColor,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Major Field
            _buildTextField(
              controller: _majorController,
              label: 'Major/Field of Study',
              hintText: 'e.g., Astro-Engineering',
              keyboardType: TextInputType.text,
              textColor: textColor,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Graduation Year Field
            _buildTextField(
              controller: _graduationYearController,
              label: 'Graduation Year',
              hintText: 'e.g., 2042',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && (value ?? []).isNotEmpty) {
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 5) {
                    return 'Please enter a valid year.';
                  }
                }
                return null;
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

            // Employment Status Dropdown
            _buildDropdownField<String>(
              label: 'Employment Status',
              value: _selectedEmploymentStatus,
              items: DummyData.employmentStatusOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedEmploymentStatus = newValue;
                  _onUpdate();
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

            // Current Job Title Field
            _buildTextField(
              controller: _currentJobTitleController,
              label: 'Current Job Title',
              hintText: 'e.g., Senior AI Strategist',
              keyboardType: TextInputType.text,
              textColor: textColor,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Company Name Field
            _buildTextField(
              controller: _companyNameController,
              label: 'Company Name',
              hintText: 'e.g., Galactic Innovations Inc.',
              keyboardType: TextInputType.text,
              textColor: textColor,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Current Salary (Text, for now)
            _buildTextField(
              controller: _currentSalaryController,
              label: 'Current Salary (Optional, for matching)',
              hintText: 'e.g., \$100,000 - \$150,000 (per annum)',
              keyboardType: TextInputType.text, // Can be number or range, keep text for flexibility
              textColor: textColor,
              surfaceColor: surfaceColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Career Aspirations Field
            _buildTextField(
              controller: _careerAspirationsController,
              label: 'Career Aspirations',
              hintText: 'Where do you see your career heading?',
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

            // Life Goals Field
            _buildTextField(
              controller: _lifeGoalsController,
              label: 'Personal Life Goals',
              hintText: 'What are your dreams and aspirations outside of work?',
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
            const SizedBox(height: AppConstants.spacingXXL), // Extra space at the bottom for scrolling
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for consistent styling (copied from PersonalAndContactForm) ---

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: AppConstants.fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2.0,
            color: AppConstants.primaryColor.withOpacity(0.4),
          ),
        ],
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
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              isExpanded: true,
              dropdownColor: surfaceColor,
              style: TextStyle(color: textColor, fontSize: AppConstants.fontSizeBody),
              icon: Icon(Icons.arrow_drop_down, color: textColor.withOpacity(0.7)),
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
}