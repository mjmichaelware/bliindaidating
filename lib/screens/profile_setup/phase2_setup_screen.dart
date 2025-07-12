import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

// CORRECTED IMPORTS for all 7 sub-tab form files
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/dating_and_relationship_goals_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/education_and_career_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/family_and_background_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/lifestyle_and_values_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/personal_and_contact_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/personality_and_self_reflection_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/physical_attributes_and_health_form.dart';


class Phase2SetupScreen extends StatefulWidget {
  const Phase2SetupScreen({super.key});

  @override
  State<Phase2SetupScreen> createState() => _Phase2SetupScreenState();
}

class _Phase2SetupScreenState extends State<Phase2SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of the 7 sub-tab form widgets
  final List<Widget> _phase2SubForms = const [
    DatingAndRelationshipGoalsForm(),
    EducationAndCareerForm(),
    FamilyAndBackgroundForm(),
    LifestyleAndValuesForm(),
    PersonalAndContactForm(),
    PersonalityAndSelfReflectionForm(),
    PhysicalAttributesAndHealthForm(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _phase2SubForms.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _submitPhase2Completion(); // All tabs completed
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitPhase2Completion() {
    // TODO: Implement actual Phase 2 profile completion logic
    // This would typically involve saving data from all sub-tabs to Supabase
    // and setting isPhase2Complete to true in the user's profile.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Phase 2 Profile Setup Complete! (Dummy Action)'),
        backgroundColor: Colors.green,
      ),
    );
    // After completion, you might navigate back to the dashboard or a confirmation screen
    // Navigator.of(context).pop(); // Example to pop back
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complete Your Profile: Phase 2',
          style: TextStyle(
            color: textColor,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _phase2SubForms.length,
                backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                color: secondaryColor,
                minHeight: 8.0,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Main Content Area for Sub-Tabs
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _phase2SubForms.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _phase2SubForms[index];
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: _goToPreviousPage,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withOpacity(0.8),
                      foregroundColor: AppConstants.textColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
                        vertical: AppConstants.paddingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      ),
                    ),
                  ),
                // Spacer to push buttons to ends if only one is visible
                if (_currentPage == 0 && _phase2SubForms.length > 1)
                  const Spacer(),

                ElevatedButton.icon(
                  onPressed: _goToNextPage,
                  icon: Icon(_currentPage == _phase2SubForms.length - 1
                      ? Icons.done_all_rounded
                      : Icons.arrow_forward_ios_rounded),
                  label: Text(_currentPage == _phase2SubForms.length - 1
                      ? 'Complete Phase 2'
                      : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: AppConstants.textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
