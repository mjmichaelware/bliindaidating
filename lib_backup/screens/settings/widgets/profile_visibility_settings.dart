// lib/screens/settings/widgets/profile_visibility_settings.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class ProfileVisibilitySettings extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  // All visibility toggles
  final bool showFullName;
  final bool showDisplayName;
  final bool showAge;
  final bool showGender;
  final bool showBio;
  final bool showSexualOrientation;
  final bool showHeight;
  final bool showInterests;
  final bool showLookingFor;
  final bool showLocation;
  final bool showEthnicity;
  final bool showLanguagesSpoken;
  final bool showEducationLevel;
  final bool showDesiredOccupation;
  final bool showLoveLanguages;
  final bool showFavoriteMedia;
  final bool showMaritalStatus;
  final bool showChildrenPreference;
  final bool showWillingToRelocate;
  final bool showMonogamyPolyamory;
  final bool showLoveRelationshipGoals;
  final bool showDealbreakersBoundaries;
  final bool showAstrologicalSign;
  final bool showAttachmentStyle;
  final bool showCommunicationStyle;
  final bool showMentalHealthDisclosures;
  final bool showPetOwnership;
  final bool showTravelFrequencyDestinations;
  final bool showPoliticalViews;
  final bool showReligionBeliefs;
  final bool showDiet;
  final bool showSmokingHabits;
  final bool showDrinkingHabits;
  final bool showExerciseFrequency;
  final bool showSleepSchedule;
  final bool showPersonalityTraits;

  // All visibility callbacks
  final Function(bool) onShowFullNameChanged;
  final Function(bool) onShowDisplayNameChanged;
  final Function(bool) onShowAgeChanged;
  final Function(bool) onShowGenderChanged;
  final Function(bool) onShowBioChanged;
  final Function(bool) onShowSexualOrientationChanged;
  final Function(bool) onShowHeightChanged;
  final Function(bool) onShowInterestsChanged;
  final Function(bool) onShowLookingForChanged;
  final Function(bool) onShowLocationChanged;
  final Function(bool) onShowEthnicityChanged;
  final Function(bool) onShowLanguagesSpokenChanged;
  final Function(bool) onShowEducationLevelChanged;
  final Function(bool) onShowDesiredOccupationChanged;
  final Function(bool) onShowLoveLanguagesChanged;
  final Function(bool) onShowFavoriteMediaChanged;
  final Function(bool) onShowMaritalStatusChanged;
  final Function(bool) onShowChildrenPreferenceChanged;
  final Function(bool) onShowWillingToRelocateChanged;
  final Function(bool) onShowMonogamyPolyamoryChanged;
  final Function(bool) onShowLoveRelationshipGoalsChanged;
  final Function(bool) onShowDealbreakersBoundariesChanged;
  final Function(bool) onShowAstrologicalSignChanged;
  final Function(bool) onShowAttachmentStyleChanged;
  final Function(bool) onShowCommunicationStyleChanged;
  final Function(bool) onShowMentalHealthDisclosuresChanged;
  final Function(bool) onShowPetOwnershipChanged;
  final Function(bool) onShowTravelFrequencyDestinationsChanged;
  final Function(bool) onShowPoliticalViewsChanged;
  final Function(bool) onShowReligionBeliefsChanged;
  final Function(bool) onShowDietChanged;
  final Function(bool) onShowSmokingHabitsChanged;
  final Function(bool) onShowDrinkingHabitsChanged;
  final Function(bool) onShowExerciseFrequencyChanged;
  final Function(bool) onShowSleepScheduleChanged;
  final Function(bool) onShowPersonalityTraitsChanged;

  const ProfileVisibilitySettings({
    super.key,
    required this.formKey,
    required this.showFullName,
    required this.showDisplayName,
    required this.showAge,
    required this.showGender,
    required this.showBio,
    required this.showSexualOrientation,
    required this.showHeight,
    required this.showInterests,
    required this.showLookingFor,
    required this.showLocation,
    required this.showEthnicity,
    required this.showLanguagesSpoken,
    required this.showEducationLevel,
    required this.showDesiredOccupation,
    required this.showLoveLanguages,
    required this.showFavoriteMedia,
    required this.showMaritalStatus,
    required this.showChildrenPreference,
    required this.showWillingToRelocate,
    required this.showMonogamyPolyamory,
    required this.showLoveRelationshipGoals,
    required this.showDealbreakersBoundaries,
    required this.showAstrologicalSign,
    required this.showAttachmentStyle,
    required this.showCommunicationStyle,
    required this.showMentalHealthDisclosures,
    required this.showPetOwnership,
    required this.showTravelFrequencyDestinations,
    required this.showPoliticalViews,
    required this.showReligionBeliefs,
    required this.showDiet,
    required this.showSmokingHabits,
    required this.showDrinkingHabits,
    required this.showExerciseFrequency,
    required this.showSleepSchedule,
    required this.showPersonalityTraits,
    required this.onShowFullNameChanged,
    required this.onShowDisplayNameChanged,
    required this.onShowAgeChanged,
    required this.onShowGenderChanged,
    required this.onShowBioChanged,
    required this.onShowSexualOrientationChanged,
    required this.onShowHeightChanged,
    required this.onShowInterestsChanged,
    required this.onShowLookingForChanged,
    required this.onShowLocationChanged,
    required this.onShowEthnicityChanged,
    required this.onShowLanguagesSpokenChanged,
    required this.onShowEducationLevelChanged,
    required this.onShowDesiredOccupationChanged,
    required this.onShowLoveLanguagesChanged,
    required this.onShowFavoriteMediaChanged,
    required this.onShowMaritalStatusChanged,
    required this.onShowChildrenPreferenceChanged,
    required this.onShowWillingToRelocateChanged,
    required this.onShowMonogamyPolyamoryChanged,
    required this.onShowLoveRelationshipGoalsChanged,
    required this.onShowDealbreakersBoundariesChanged,
    required this.onShowAstrologicalSignChanged,
    required this.onShowAttachmentStyleChanged,
    required this.onShowCommunicationStyleChanged,
    required this.onShowMentalHealthDisclosuresChanged,
    required this.onShowPetOwnershipChanged,
    required this.onShowTravelFrequencyDestinationsChanged,
    required this.onShowPoliticalViewsChanged,
    required this.onShowReligionBeliefsChanged,
    required this.onShowDietChanged,
    required this.onShowSmokingHabitsChanged,
    required this.onShowDrinkingHabitsChanged,
    required this.onShowExerciseFrequencyChanged,
    required this.onShowSleepScheduleChanged,
    required this.onShowPersonalityTraitsChanged,
  });

  @override
  State<ProfileVisibilitySettings> createState() => _ProfileVisibilitySettingsState();
}

class _ProfileVisibilitySettingsState extends State<ProfileVisibilitySettings> {
  bool _showMoreOptions = false; // State to control expansion

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? Colors.deepPurple.shade800 : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Visibility',
              style: textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Control which information is visible on your blurred profile card.',
              style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 24),

            // --- Section: Core Profile Details (Always Visible Initially) ---
            _buildCategoryHeader('Core Profile Details', textTheme, textColor),
            const SizedBox(height: 16),
            _buildVisibilityToggle('Display Name', widget.showDisplayName, widget.onShowDisplayNameChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Age', widget.showAge, widget.onShowAgeChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Gender', widget.showGender, widget.onShowGenderChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Location (ZIP/City)', widget.showLocation, widget.onShowLocationChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Looking For', widget.showLookingFor, widget.onShowLookingForChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('About Me (Bio)', widget.showBio, widget.onShowBioChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Sexual Orientation', widget.showSexualOrientation, widget.onShowSexualOrientationChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Height', widget.showHeight, widget.onShowHeightChanged, isDarkMode, textTheme, secondaryColor, cardColor),
            _buildVisibilityToggle('Interests', widget.showInterests, widget.onShowInterestsChanged, isDarkMode, textTheme, secondaryColor, cardColor),

            const SizedBox(height: 24),

            // --- "More Options" Button ---
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showMoreOptions = !_showMoreOptions;
                  });
                },
                icon: Icon(_showMoreOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                label: Text(_showMoreOptions ? 'Hide Advanced Options' : 'Show More Options'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor.withOpacity(0.1),
                  foregroundColor: secondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Collapsible Section for More Options ---
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showMoreOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(), // Hidden state
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader('Additional Profile Details', textTheme, textColor),
                  const SizedBox(height: 16),
                  _buildVisibilityToggle('Full Legal Name', widget.showFullName, widget.onShowFullNameChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Ethnicity', widget.showEthnicity, widget.onShowEthnicityChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Languages Spoken', widget.showLanguagesSpoken, widget.onShowLanguagesSpokenChanged, isDarkMode, textTheme, secondaryColor, cardColor),

                  const SizedBox(height: 24),
                  _buildCategoryHeader('Lifestyle & Preferences', textTheme, textColor),
                  const SizedBox(height: 16),
                  _buildVisibilityToggle('Education Level', widget.showEducationLevel, widget.onShowEducationLevelChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Desired Occupation', widget.showDesiredOccupation, widget.onShowDesiredOccupationChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Love Languages', widget.showLoveLanguages, widget.onShowLoveLanguagesChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Favorite Media', widget.showFavoriteMedia, widget.onShowFavoriteMediaChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Marital Status', widget.showMaritalStatus, widget.onShowMaritalStatusChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Children Preference', widget.showChildrenPreference, widget.onShowChildrenPreferenceChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Willing to Relocate', widget.showWillingToRelocate, widget.onShowWillingToRelocateChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Monogamy/Polyamory', widget.showMonogamyPolyamory, widget.onShowMonogamyPolyamoryChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Love/Relationship Goals', widget.showLoveRelationshipGoals, widget.onShowLoveRelationshipGoalsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Dealbreakers/Boundaries', widget.showDealbreakersBoundaries, widget.onShowDealbreakersBoundariesChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Astrological Sign', widget.showAstrologicalSign, widget.onShowAstrologicalSignChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Attachment Style', widget.showAttachmentStyle, widget.onShowAttachmentStyleChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Communication Style', widget.showCommunicationStyle, widget.onShowCommunicationStyleChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Mental Health Disclosures', widget.showMentalHealthDisclosures, widget.onShowMentalHealthDisclosuresChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Pet Ownership', widget.showPetOwnership, widget.onShowPetOwnershipChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Travel Frequency / Destinations', widget.showTravelFrequencyDestinations, widget.onShowTravelFrequencyDestinationsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Political Views', widget.showPoliticalViews, widget.onShowPoliticalViewsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Religion / Beliefs', widget.showReligionBeliefs, widget.onShowReligionBeliefsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Diet', widget.showDiet, widget.onShowDietChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Smoking Habits', widget.showSmokingHabits, widget.onShowSmokingHabitsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Drinking Habits', widget.showDrinkingHabits, widget.onShowDrinkingHabitsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Exercise Frequency', widget.showExerciseFrequency, widget.onShowExerciseFrequencyChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Sleep Schedule', widget.showSleepSchedule, widget.onShowSleepScheduleChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                  _buildVisibilityToggle('Personality Traits', widget.showPersonalityTraits, widget.onShowPersonalityTraitsChanged, isDarkMode, textTheme, secondaryColor, cardColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Note: Your analysis photo, legal name, and verified contact info are always visible to the system for safety and compliance, but are not displayed publicly unless explicitly chosen.',
              style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', fontStyle: FontStyle.italic, color: textColor.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, TextTheme textTheme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(String title, bool value, Function(bool) onChanged, bool isDarkMode, TextTheme textTheme, Color secondaryColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', color: isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: secondaryColor,
            inactiveThumbColor: cardColor,
            inactiveTrackColor: cardColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}