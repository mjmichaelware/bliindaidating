// lib/screens/profile_setup/widgets/phase2_profile_data_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';

// Import all your sub-forms here:
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/personal_and_contact_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/education_and_career_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/lifestyle_and_values_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/physical_attributes_and_health_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/dating_and_relationship_goals_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/family_and_background_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/phase2_profile_sub_tabs/personality_and_self_reflection_form.dart';

class Phase2ProfileDataTab extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate; // Callback to update parent state

  const Phase2ProfileDataTab({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<Phase2ProfileDataTab> createState() => _Phase2ProfileDataTabState();
}

class _Phase2ProfileDataTabState extends State<Phase2ProfileDataTab>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController; // For the tab indicators at the top
  int _currentPage = 0;

  // Track the UserProfile state within this widget to pass down to children
  late UserProfile _currentUserProfile;

  // List of forms to display in the PageView
  late final List<Widget> _forms;

  @override
  void initState() {
    super.initState();
    _currentUserProfile = widget.userProfile; // Initialize with passed profile

    _forms = [
      PersonalAndContactForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      EducationAndCareerForm( // Assuming this one is already implemented or placeholder
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      LifestyleAndValuesForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      PhysicalAttributesAndHealthForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      DatingAndRelationshipGoalsForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      FamilyAndBackgroundForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
      PersonalityAndSelfReflectionForm(
        userProfile: _currentUserProfile,
        onUpdate: _updateSubProfile,
      ),
    ];

    _pageController = PageController(initialPage: _currentPage);
    _tabController = TabController(length: _forms.length, vsync: this);

    _pageController.addListener(() {
      if (_pageController.page != null && _pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
          _tabController.animateTo(_currentPage);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Callback function passed to children to update the main UserProfile
  void _updateSubProfile(UserProfile updatedSubProfile) {
    setState(() {
      _currentUserProfile = updatedSubProfile;
      widget.onUpdate(_currentUserProfile); // Propagate up to the parent widget
    });
  }

  void _goToNextPage() {
    if (_currentPage < _forms.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Logic for when all forms are completed, e.g., navigate away
      _showCompletionDialog();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showCompletionDialog() {
    final themeController = Provider.of<ThemeController>(context, listen: false);
    final bool isDarkMode = themeController.isDarkMode;
    final Color dialogBackgroundColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color dialogTextColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            side: BorderSide(color: AppConstants.accentColor.withOpacity(0.5), width: 1.5),
          ),
          title: Text(
            "Profile Complete!",
            style: AppConstants.titleTextStyle.copyWith(color: AppConstants.accentColor),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "You've filled out all your cosmic details. Your profile is ready for blast-off!",
            style: AppConstants.subtitleTextStyle.copyWith(color: dialogTextColor.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Awesome!",
                style: AppConstants.buttonTextStyle.copyWith(color: AppConstants.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to dashboard or next phase
                // Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final bool isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color primaryColor = AppConstants.primaryColor;
    final Color accentColor = isDarkMode ? AppConstants.accentColor : AppConstants.lightAccentColor;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by parent
      body: Column(
        children: [
          // Progress Indicator & Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentPage + 1) / _forms.length,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: AppConstants.spacingExtraSmall,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                SizedBox(
                  height: 40, // Height for the TabBar
                  child: Theme( // Apply a custom theme for TabBar indicators
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: AppConstants.primaryColor.toMaterialColor(),
                      ).copyWith(
                        secondary: accentColor, // Indicator color
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: accentColor,
                      indicatorWeight: 3.0,
                      labelColor: accentColor,
                      unselectedLabelColor: textColor.withOpacity(0.6),
                      labelStyle: AppConstants.buttonTextStyle.copyWith(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: AppConstants.buttonTextStyle.copyWith(fontWeight: FontWeight.normal),
                      tabs: _forms.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String label = '';
                        if (entry.value is PersonalAndContactForm) label = 'Identity';
                        if (entry.value is EducationAndCareerForm) label = 'Career';
                        if (entry.value is LifestyleAndValuesForm) label = 'Lifestyle';
                        if (entry.value is PhysicalAttributesAndHealthForm) label = 'Physique';
                        if (entry.value is DatingAndRelationshipGoalsForm) label = 'Dating Goals';
                        if (entry.value is FamilyAndBackgroundForm) label = 'Family';
                        if (entry.value is PersonalityAndSelfReflectionForm) label = 'Personality';
                        return Tab(text: label);
                      }).toList(),
                      onTap: (index) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to navigate
              children: _forms,
            ),
          ),
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                _currentPage > 0
                    ? _buildGradientButton(
                        label: 'Previous',
                        onPressed: _goToPreviousPage,
                        isDarkMode: isDarkMode,
                        icon: Icons.arrow_back_ios_new,
                        isLeadingIcon: true,
                      )
                    : SizedBox(width: AppConstants.buttonWidthDefault), // Placeholder to keep spacing
                // Next Button
                _buildGradientButton(
                  label: _currentPage == _forms.length - 1 ? 'Finish' : 'Next',
                  onPressed: _goToNextPage,
                  isDarkMode: isDarkMode,
                  icon: _currentPage == _forms.length - 1 ? Icons.check_circle_outline : Icons.arrow_forward_ios,
                  isLeadingIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
    required bool isDarkMode,
    required IconData icon,
    required bool isLeadingIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.8),
            AppConstants.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: AppConstants.elevationMedium,
            spreadRadius: AppConstants.elevationExtraSmall,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          splashColor: AppConstants.textHighEmphasis.withOpacity(0.3),
          highlightColor: AppConstants.textHighEmphasis.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLeadingIcon) Icon(icon, color: AppConstants.textHighEmphasis, size: AppConstants.fontSizeIcon),
                if (isLeadingIcon) const SizedBox(width: AppConstants.spacingSmall),
                Text(
                  label,
                  style: AppConstants.buttonTextStyle.copyWith(color: AppConstants.textHighEmphasis),
                ),
                if (!isLeadingIcon) const SizedBox(width: AppConstants.spacingSmall),
                if (!isLeadingIcon) Icon(icon, color: AppConstants.textHighEmphasis, size: AppConstants.fontSizeIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}