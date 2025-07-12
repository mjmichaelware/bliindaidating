// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

import 'package:bliindaidating/screens/settings/widgets/dating_preferences_form.dart';
import 'package:bliindaidating/screens/settings/widgets/profile_visibility_settings.dart';
import 'package:bliindaidating/screens/settings/widgets/account_settings_form.dart';
import 'package:bliindaidating/screens/settings/widgets/notification_settings.dart';
import 'package:bliindaidating/screens/settings/widgets/privacy_data_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;

  // --- Dating Preferences State ---
  String? _preferredGender;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100; // in miles

  // --- Profile Visibility State ---
  // Initializing all to false for demonstration; these would be loaded from DB
  bool _showFullName = false;
  bool _showDisplayName = true;
  bool _showAge = true;
  bool _showGender = true;
  bool _showBio = true;
  bool _showSexualOrientation = true;
  bool _showHeight = true;
  bool _showInterests = true;
  bool _showLookingFor = true;
  bool _showLocation = true;
  bool _showEthnicity = false;
  bool _showLanguagesSpoken = false;
  bool _showEducationLevel = false;
  bool _showDesiredOccupation = false;
  bool _showLoveLanguages = false;
  bool _showFavoriteMedia = false;
  bool _showMaritalStatus = false;
  bool _showChildrenPreference = false;
  bool _showWillingToRelocate = false;
  bool _showMonogamyPolyamory = false;
  bool _showLoveRelationshipGoals = false;
  bool _showDealbreakersBoundaries = false;
  bool _showAstrologicalSign = false;
  bool _showAttachmentStyle = false;
  bool _showCommunicationStyle = false;
  bool _showMentalHealthDisclosures = false;
  bool _showPetOwnership = false;
  bool _showTravelFrequencyDestinations = false;
  bool _showPoliticalViews = false;
  bool _showReligionBeliefs = false;
  bool _showDiet = false;
  bool _showSmokingHabits = false;
  bool _showDrinkingHabits = false;
  bool _showExerciseFrequency = false;
  bool _showSleepSchedule = false;
  bool _showPersonalityTraits = false;


  // Tab Definitions
  static const List<Tab> _settingsTabs = <Tab>[
    Tab(text: 'Dating Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Profile Visibility', icon: Icon(Icons.visibility)),
    Tab(text: 'Account', icon: Icon(Icons.manage_accounts)),
    Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
    Tab(text: 'Privacy & Data', icon: Icon(Icons.security)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _settingsTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPreferences();
  }

  void _handleTabChange() {
    setState(() {});
  }

  Future<void> _loadPreferences() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        debugPrint('SettingsScreen: No current user, redirecting to login.');
        context.go('/login');
      }
      return;
    }

    try {
      final UserProfile? userProfile = await _profileService.fetchUserProfile(currentUser.id);
      if (userProfile != null) {
        // TODO: Load actual saved settings from user_profile or a dedicated settings table
        _preferredGender = 'Any';
        _ageRange = const RangeValues(20, 40);
        _maxDistance = 50;

        // Mock loading visibility settings (assuming they would be stored in UserProfile or a separate settings model)
        _showFullName = userProfile.fullName != null;
        _showDisplayName = userProfile.displayName != null;
        _showAge = userProfile.dateOfBirth != null;
        _showGender = userProfile.gender != null;
        _showBio = userProfile.bio != null;
        _showSexualOrientation = userProfile.sexualOrientation != null;
        _showHeight = userProfile?.height != null;
        _showInterests = userProfile.(interests ?? []).isNotEmpty;
        _showLookingFor = userProfile.lookingFor != null;
        _showLocation = userProfile.addressZip != null;
        _showEthnicity = false; // Mock values
        _showLanguagesSpoken = false;
        _showEducationLevel = false;
        _showDesiredOccupation = false;
        _showLoveLanguages = false;
        _showFavoriteMedia = false;
        _showMaritalStatus = false;
        _showChildrenPreference = false;
        _showWillingToRelocate = false;
        _showMonogamyPolyamory = false;
        _showLoveRelationshipGoals = false;
        _showDealbreakersBoundaries = false;
        _showAstrologicalSign = false;
        _showAttachmentStyle = false;
        _showCommunicationStyle = false;
        _showMentalHealthDisclosures = false;
        _showPetOwnership = false;
        _showTravelFrequencyDestinations = false;
        _showPoliticalViews = false;
        _showReligionBeliefs = false;
        _showDiet = false;
        _showSmokingHabits = false;
        _showDrinkingHabits = false;
        _showExerciseFrequency = false;
        _showSleepSchedule = false;
        _showPersonalityTraits = false;
      }
      debugPrint('SettingsScreen: Preferences loaded (mock/initial)');
    } catch (e) {
      debugPrint('SettingsScreen: Error loading preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKeys[_tabController.index].currentState!.validate()) {
      debugPrint('SettingsScreen: Validation failed for current tab.');
      return;
    }

    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        context.go('/login');
      }
      setState(() { _isLoading = false; });
      return;
    }

    try {
      debugPrint('SettingsScreen: Saving preferences...');
      debugPrint('  Dating: Preferred Gender: $_preferredGender, Age: ${_ageRange.start.toInt()}-${_ageRange.end.toInt()}, Distance: ${_maxDistance.toInt()} miles');
      debugPrint('  Visibility: FullName: $_showFullName, DisplayName: $_showDisplayName, etc.');
      debugPrint('  All visibility states: $_showFullName, $_showDisplayName, $_showAge, $_showGender, $_showBio, $_showSexualOrientation, $_showHeight, $_showInterests, $_showLookingFor, $_showLocation, $_showEthnicity, $_showLanguagesSpoken, $_showEducationLevel, $_showDesiredOccupation, $_showLoveLanguages, $_showFavoriteMedia, $_showMaritalStatus, $_showChildrenPreference, $_showWillingToRelocate, $_showMonogamyPolyamory, $_showLoveRelationshipGoals, $_showDealbreakersBoundaries, $_showAstrologicalSign, $_showAttachmentStyle, $_showCommunicationStyle, $_showMentalHealthDisclosures, $_showPetOwnership, $_showTravelFrequencyDestinations, $_showPoliticalViews, $_showReligionBeliefs, $_showDiet, $_showSmokingHabits, $_showDrinkingHabits, $_showExerciseFrequency, $_showSleepSchedule, $_showPersonalityTraits');

      // TODO: Implement actual saving logic to Supabase
      // This will involve updating UserProfile with new fields or a dedicated UserSettings table.
      // Example:
      // final UserProfile? currentProfile = await _profileService.fetchUserProfile(currentUser.id);
      // if (currentProfile != null) {
      //   final UserProfile updatedProfile = currentProfile.copyWith(
      //     // Add all new preference and visibility fields here
      //     preferredGender: _preferredGender,
      //     minAgePreference: _ageRange.start.toInt(),
      //     maxAgePreference: _ageRange.end.toInt(),
      //     maxSearchDistanceMiles: _maxDistance,
      //     showFullName: _showFullName,
      //     showDisplayName: _showDisplayName,
      //     // ... and so on for all 30+ visibility settings
      //   );
      //   await _profileService.createOrUpdateProfile(profile: updatedProfile);
      // }


      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      debugPrint('SettingsScreen: Preferences saved successfully (mock)!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('SettingsScreen: Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // --- Callbacks for child widgets to update parent state ---
  void _onPreferredGenderChanged(String? newValue) { setState(() { _preferredGender = newValue; }); }
  void _onAgeRangeChanged(RangeValues newValues) { setState(() { _ageRange = newValues; }); }
  void _onMaxDistanceChanged(double newValue) { setState(() { _maxDistance = newValue; }); }

  // Callbacks for Profile Visibility Toggles
  void _onShowFullNameChanged(bool newValue) { setState(() { _showFullName = newValue; }); }
  void _onShowDisplayNameChanged(bool newValue) { setState(() { _showDisplayName = newValue; }); }
  void _onShowAgeChanged(bool newValue) { setState(() { _showAge = newValue; }); }
  void _onShowGenderChanged(bool newValue) { setState(() { _showGender = newValue; }); }
  void _onShowBioChanged(bool newValue) { setState(() { _showBio = newValue; }); }
  void _onShowSexualOrientationChanged(bool newValue) { setState(() { _showSexualOrientation = newValue; }); }
  void _onShowHeightChanged(bool newValue) { setState(() { _showHeight = newValue; }); }
  void _onShowInterestsChanged(bool newValue) { setState(() { _showInterests = newValue; }); }
  void _onShowLookingForChanged(bool newValue) { setState(() { _showLookingFor = newValue; }); }
  void _onShowLocationChanged(bool newValue) { setState(() { _showLocation = newValue; }); }
  void _onShowEthnicityChanged(bool newValue) { setState(() { _showEthnicity = newValue; }); }
  void _onShowLanguagesSpokenChanged(bool newValue) { setState(() { _showLanguagesSpoken = newValue; }); }
  void _onShowEducationLevelChanged(bool newValue) { setState(() { _showEducationLevel = newValue; }); }
  void _onShowDesiredOccupationChanged(bool newValue) { setState(() { _showDesiredOccupation = newValue; }); }
  void _onShowLoveLanguagesChanged(bool newValue) { setState(() { _showLoveLanguages = newValue; }); }
  void _onShowFavoriteMediaChanged(bool newValue) { setState(() { _showFavoriteMedia = newValue; }); }
  void _onShowMaritalStatusChanged(bool newValue) { setState(() { _showMaritalStatus = newValue; }); }
  void _onShowChildrenPreferenceChanged(bool newValue) { setState(() { _showChildrenPreference = newValue; }); }
  void _onShowWillingToRelocateChanged(bool newValue) { setState(() { _showWillingToRelocate = newValue; }); }
  void _onShowMonogamyPolyamoryChanged(bool newValue) { setState(() { _showMonogamyPolyamory = newValue; }); }
  void _onShowLoveRelationshipGoalsChanged(bool newValue) { setState(() { _showLoveRelationshipGoals = newValue; }); }
  void _onShowDealbreakersBoundariesChanged(bool newValue) { setState(() { _showDealbreakersBoundaries = newValue; }); }
  void _onShowAstrologicalSignChanged(bool newValue) { setState(() { _showAstrologicalSign = newValue; }); }
  void _onShowAttachmentStyleChanged(bool newValue) { setState(() { _showAttachmentStyle = newValue; }); }
  void _onShowCommunicationStyleChanged(bool newValue) { setState(() { _showCommunicationStyle = newValue; }); }
  void _onShowMentalHealthDisclosuresChanged(bool newValue) { setState(() { _showMentalHealthDisclosures = newValue; }); }
  void _onShowPetOwnershipChanged(bool newValue) { setState(() { _showPetOwnership = newValue; }); }
  void _onShowTravelFrequencyDestinationsChanged(bool newValue) { setState(() { _showTravelFrequencyDestinations = newValue; }); }
  void _onShowPoliticalViewsChanged(bool newValue) { setState(() { _showPoliticalViews = newValue; }); }
  void _onShowReligionBeliefsChanged(bool newValue) { setState(() { _showReligionBeliefs = newValue; }); }
  void _onShowDietChanged(bool newValue) { setState(() { _showDiet = newValue; }); }
  void _onShowSmokingHabitsChanged(bool newValue) { setState(() { _showSmokingHabits = newValue; }); }
  void _onShowDrinkingHabitsChanged(bool newValue) { setState(() { _showDrinkingHabits = newValue; }); }
  void _onShowExerciseFrequencyChanged(bool newValue) { setState(() { _showExerciseFrequency = newValue; }); }
  void _onShowSleepScheduleChanged(bool newValue) { setState(() { _showSleepSchedule = newValue; }); }
  void _onShowPersonalityTraitsChanged(bool newValue) { setState(() { _showPersonalityTraits = newValue; }); }


  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    final Color primaryColor = isDarkMode ? Colors.deepPurpleAccent : Colors.blue.shade700;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color accentColor = isDarkMode ? Colors.cyanAccent : Colors.orangeAccent;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            if (mounted) context.pop();
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _settingsTabs,
          labelColor: accentColor,
          unselectedLabelColor: textColor.withOpacity(0.7),
          indicatorColor: accentColor,
          labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
          isScrollable: true,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                DatingPreferencesForm(
                  formKey: _formKeys?[0],
                  preferredGender: _preferredGender,
                  ageRange: _ageRange,
                  maxDistance: _maxDistance,
                  onPreferredGenderChanged: _onPreferredGenderChanged,
                  onAgeRangeChanged: _onAgeRangeChanged,
                  onMaxDistanceChanged: _onMaxDistanceChanged,
                ),
                ProfileVisibilitySettings(
                  formKey: _formKeys?[1],
                  showFullName: _showFullName,
                  showDisplayName: _showDisplayName,
                  showAge: _showAge,
                  showGender: _showGender,
                  showBio: _showBio,
                  showSexualOrientation: _showSexualOrientation,
                  showHeight: _showHeight,
                  showInterests: _showInterests,
                  showLookingFor: _showLookingFor,
                  showLocation: _showLocation,
                  onShowFullNameChanged: _onShowFullNameChanged,
                  onShowDisplayNameChanged: _onShowDisplayNameChanged,
                  onShowAgeChanged: _onShowAgeChanged,
                  onShowGenderChanged: _onShowGenderChanged,
                  onShowBioChanged: _onShowBioChanged,
                  onShowSexualOrientationChanged: _onShowSexualOrientationChanged,
                  onShowHeightChanged: _onShowHeightChanged,
                  onShowInterestsChanged: _onShowInterestsChanged,
                  onShowLookingForChanged: _onShowLookingForChanged,
                  onShowLocationChanged: _onShowLocationChanged,
                  // Pass all new visibility parameters
                  showEthnicity: _showEthnicity,
                  showLanguagesSpoken: _showLanguagesSpoken,
                  showEducationLevel: _showEducationLevel,
                  showDesiredOccupation: _showDesiredOccupation,
                  showLoveLanguages: _showLoveLanguages,
                  showFavoriteMedia: _showFavoriteMedia,
                  showMaritalStatus: _showMaritalStatus,
                  showChildrenPreference: _showChildrenPreference,
                  showWillingToRelocate: _showWillingToRelocate,
                  showMonogamyPolyamory: _showMonogamyPolyamory,
                  showLoveRelationshipGoals: _showLoveRelationshipGoals,
                  showDealbreakersBoundaries: _showDealbreakersBoundaries,
                  showAstrologicalSign: _showAstrologicalSign,
                  showAttachmentStyle: _showAttachmentStyle,
                  showCommunicationStyle: _showCommunicationStyle,
                  showMentalHealthDisclosures: _showMentalHealthDisclosures,
                  showPetOwnership: _showPetOwnership,
                  showTravelFrequencyDestinations: _showTravelFrequencyDestinations,
                  showPoliticalViews: _showPoliticalViews,
                  showReligionBeliefs: _showReligionBeliefs,
                  showDiet: _showDiet,
                  showSmokingHabits: _showSmokingHabits,
                  showDrinkingHabits: _showDrinkingHabits,
                  showExerciseFrequency: _showExerciseFrequency,
                  showSleepSchedule: _showSleepSchedule,
                  showPersonalityTraits: _showPersonalityTraits,
                  onShowEthnicityChanged: _onShowEthnicityChanged,
                  onShowLanguagesSpokenChanged: _onShowLanguagesSpokenChanged,
                  onShowEducationLevelChanged: _onShowEducationLevelChanged,
                  onShowDesiredOccupationChanged: _onShowDesiredOccupationChanged,
                  onShowLoveLanguagesChanged: _onShowLoveLanguagesChanged,
                  onShowFavoriteMediaChanged: _onShowFavoriteMediaChanged,
                  onShowMaritalStatusChanged: _onShowMaritalStatusChanged,
                  onShowChildrenPreferenceChanged: _onShowChildrenPreferenceChanged,
                  onShowWillingToRelocateChanged: _onShowWillingToRelocateChanged,
                  onShowMonogamyPolyamoryChanged: _onShowMonogamyPolyamoryChanged,
                  onShowLoveRelationshipGoalsChanged: _onShowLoveRelationshipGoalsChanged,
                  onShowDealbreakersBoundariesChanged: _onShowDealbreakersBoundariesChanged,
                  onShowAstrologicalSignChanged: _onShowAstrologicalSignChanged,
                  onShowAttachmentStyleChanged: _onShowAttachmentStyleChanged,
                  onShowCommunicationStyleChanged: _onShowCommunicationStyleChanged,
                  onShowMentalHealthDisclosuresChanged: _onShowMentalHealthDisclosuresChanged,
                  onShowPetOwnershipChanged: _onShowPetOwnershipChanged,
                  onShowTravelFrequencyDestinationsChanged: _onShowTravelFrequencyDestinationsChanged,
                  onShowPoliticalViewsChanged: _onShowPoliticalViewsChanged,
                  onShowReligionBeliefsChanged: _onShowReligionBeliefsChanged,
                  onShowDietChanged: _onShowDietChanged,
                  onShowSmokingHabitsChanged: _onShowSmokingHabitsChanged,
                  onShowDrinkingHabitsChanged: _onShowDrinkingHabitsChanged,
                  onShowExerciseFrequencyChanged: _onShowExerciseFrequencyChanged,
                  onShowSleepScheduleChanged: _onShowSleepScheduleChanged,
                  onShowPersonalityTraitsChanged: _onShowPersonalityTraitsChanged,
                ),
                AccountSettingsForm(formKey: _formKeys?[2]),
                NotificationSettings(formKey: _formKeys?[3]),
                PrivacyDataSettings(formKey: _formKeys?[4]),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Save All Settings',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
          ),
        ),
      ),
    );
  }
}