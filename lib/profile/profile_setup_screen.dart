// lib/screens/profile_setup/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Keep this for debugPrint
import 'dart:io';

// Import custom background/effects for immersion
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

// Import the modular form widgets
import 'package:bliindaidating/screens/profile_setup/widgets/basic_info_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/identity_id_form.dart'; // Corrected import path
import 'package:bliindaidating/screens/profile_setup/widgets/preferences_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/consent_form.dart';


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  bool _isLoading = true;
  // Track if a navigation attempt has already been made to avoid multiple redirects
  bool _isNavigating = false;


  XFile? _pickedImage;
  String? _imagePreviewPath;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController(); // Corresponds to locationZipCode
  final TextEditingController _bioController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender; // Will be mapped to genderIdentity
  String? _sexualOrientation;
  String? _lookingFor;
  List<String> _selectedInterests = []; // Will be mapped to hobbiesAndInterests
  bool _agreedToTerms = false;
  bool _agreedToCommunityGuidelines = false;

  String? _preferredGender;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100;

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
  bool _showSleepSchedule = false;

  static const List<Tab> _profileTabs = <Tab>[
    Tab(text: 'Basic Info', icon: Icon(Icons.person)),
    Tab(text: 'Identity & Connection', icon: Icon(Icons.perm_identity)),
    Tab(text: 'Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Consent', icon: Icon(Icons.policy)),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileSetupScreen: initState called.');
    _tabController = TabController(length: _profileTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPreferences();
  }

  @override
  void dispose() {
    debugPrint('ProfileSetupScreen: dispose called.');
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _heightController.dispose();
    _phoneNumberController.dispose();
    _addressZipController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    debugPrint('ProfileSetupScreen: Tab changed to index ${_tabController.index}.');
    setState(() {});
  }

  void _onImagePicked(XFile? image) {
    debugPrint('ProfileSetupScreen: Image picked: ${image?.path}');
    setState(() {
      _pickedImage = image;
      _imagePreviewPath = image?.path;
    });
  }

  void _onDateOfBirthSelected(DateTime? newDate) {
    debugPrint('ProfileSetupScreen: Date of birth selected: $newDate');
    setState(() {
      _dateOfBirth = newDate;
    });
  }

  void _onGenderChanged(String? newGender) {
    debugPrint('ProfileSetupScreen: Gender changed to: $newGender');
    setState(() {
      _gender = newGender;
    });
  }

  void _onSexualOrientationChanged(String? newSexualOrientation) {
    debugPrint('ProfileSetupScreen: Sexual Orientation changed to: $newSexualOrientation');
    setState(() {
      _sexualOrientation = newSexualOrientation;
    });
  }

  void _onLookingForChanged(String? newLookingFor) {
    debugPrint('ProfileSetupScreen: Looking For changed to: $newLookingFor');
    setState(() {
      _lookingFor = newLookingFor;
    });
  }

  void _onInterestSelected(String interest) {
    debugPrint('ProfileSetupScreen: Interest selected: $interest');
    setState(() {
      if (!_selectedInterests.contains(interest)) {
        _selectedInterests.add(interest);
      }
    });
  }

  void _onInterestDeselected(String interest) {
    debugPrint('ProfileSetupScreen: Interest deselected: $interest');
    setState(() {
      _selectedInterests.remove(interest);
    });
  }

  void _onTermsChanged(bool? value) {
    debugPrint('ProfileSetupScreen: Agreed to Terms changed to: $value');
    setState(() {
      _agreedToTerms = value ?? false;
    });
  }

  void _onCommunityGuidelinesChanged(bool? value) {
    debugPrint('ProfileSetupScreen: Agreed to Community Guidelines changed to: $value');
    setState(() {
      _agreedToCommunityGuidelines = value ?? false;
    });
  }

  void _onMaritalStatusChanged(String? newMaritalStatus) {
    debugPrint('ProfileSetupScreen: Marital Status changed to: $newMaritalStatus');
  }


  Future<void> _loadPreferences() async {
    debugPrint('ProfileSetupScreen: _loadPreferences started.');
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        debugPrint('ProfileSetupScreen: No current user during load, redirecting to login.');
        // Ensure you don't navigate if already navigating
        if (!_isNavigating) {
          _isNavigating = true; // Set flag
          context.go('/login');
          debugPrint('ProfileSetupScreen: Issued navigation to /login from _loadPreferences.');
        }
      }
      return;
    }

    final profileService = Provider.of<ProfileService>(context, listen: false);

    try {
      debugPrint('ProfileSetupScreen: Fetching user profile for ID: ${currentUser.id}');
      final UserProfile? userProfile = await profileService.fetchUserProfile(id: currentUser.id);
      if (userProfile != null) {
        debugPrint('ProfileSetupScreen: User profile fetched. Populating fields.');
        _fullNameController.text = userProfile.fullLegalName ?? userProfile.fullName ?? '';
        _displayNameController.text = userProfile.displayName ?? '';
        _heightController.text = userProfile.heightCm?.toString() ?? userProfile.height?.toString() ?? '';
        _phoneNumberController.text = userProfile.phoneNumber ?? '';
        _addressZipController.text = userProfile.locationZipCode ?? userProfile.addressZip ?? '';
        _bioController.text = userProfile.bio ?? '';

        _dateOfBirth = userProfile.dateOfBirth;
        _gender = userProfile.genderIdentity ?? userProfile.gender;
        _sexualOrientation = userProfile.sexualOrientation;
        _lookingFor = userProfile.lookingFor;
        _selectedInterests = List.from(userProfile.hobbiesAndInterests);
        _agreedToTerms = userProfile.agreedToTerms;
        _agreedToCommunityGuidelines = userProfile.agreedToCommunityGuidelines;
        _imagePreviewPath = userProfile.profilePictureUrl;

        _preferredGender = userProfile.genderIdentity ?? userProfile.gender;

        // Visibility toggles
        _showFullName = userProfile.fullLegalName != null || userProfile.fullName != null;
        _showDisplayName = userProfile.displayName != null;
        _showAge = userProfile.dateOfBirth != null;
        _showGender = userProfile.genderIdentity != null || userProfile.gender != null;
        _showBio = userProfile.bio != null;
        _showSexualOrientation = userProfile.sexualOrientation != null;
        _showHeight = userProfile.heightCm != null || userProfile.height != null;
        _showInterests = userProfile.hobbiesAndInterests.isNotEmpty || (userProfile.interests?.isNotEmpty ?? false);
        _showLookingFor = userProfile.lookingFor != null;
        _showLocation = userProfile.locationZipCode != null || userProfile.addressZip != null;
        _showEthnicity = userProfile.ethnicity != null;
        _showLanguagesSpoken = userProfile.languagesSpoken.isNotEmpty;
        _showEducationLevel = userProfile.educationLevel != null;
        _showDesiredOccupation = userProfile.desiredOccupation != null;
        _showLoveLanguages = userProfile.loveLanguages.isNotEmpty;
        _showFavoriteMedia = userProfile.favoriteMedia.isNotEmpty;
        _showMaritalStatus = userProfile.maritalStatus != null;
        _showChildrenPreference = userProfile.hasChildren != null || userProfile.wantsChildren != null;
        _showWillingToRelocate = userProfile.willingToRelocate != null;
        _showMonogamyPolyamory = userProfile.monogamyVsPolyamoryPreferences != null;
        _showLoveRelationshipGoals = userProfile.relationshipGoals != null;
        _showDealbreakersBoundaries = userProfile.dealbreakers.isNotEmpty;
        _showAstrologicalSign = userProfile.astrologicalSign != null;
        _showAttachmentStyle = userProfile.attachmentStyle != null;
        _showCommunicationStyle = userProfile.communicationStyle != null;
        _showMentalHealthDisclosures = userProfile.mentalHealthDisclosures != null;
        _showPetOwnership = userProfile.petOwnership != null;
        _showTravelFrequencyDestinations = userProfile.travelFrequencyOrFavoriteDestinations != null;
        _showPoliticalViews = userProfile.politicalViews != null;
        _showReligionBeliefs = userProfile.religionOrSpiritualBeliefs != null;
        _showDiet = userProfile.diet != null;
        _showSmokingHabits = userProfile.smokingHabits != null;
        _showDrinkingHabits = userProfile.drinkingHabits != null;
        _showSleepSchedule = userProfile.sleepSchedule != null;
      } else {
        debugPrint('ProfileSetupScreen: No existing user profile found for ID: ${currentUser.id}.');
      }
      debugPrint('ProfileSetupScreen: Preferences loading process completed.');
    } on PostgrestException catch (e) {
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error loading preferences: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('ProfileSetupScreen: Generic Error loading preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
      debugPrint('ProfileSetupScreen: _loadPreferences finally block executed. _isLoading set to false.');
    }
  }

  Future<void> _savePreferences() async {
    debugPrint('ProfileSetupScreen: _savePreferences started.');
    if (!_formKeys[_tabController.index].currentState!.validate()) {
      debugPrint('ProfileSetupScreen: Validation failed for current tab (index: ${_tabController.index}).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields on this tab.')),
        );
      }
      return; // Exit if validation fails
    }

    setState(() { _isLoading = true; });
    debugPrint('ProfileSetupScreen: _isLoading set to true.');

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('ProfileSetupScreen: No current user found for saving. Redirecting to login.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        // Prevent multiple navigations
        if (!_isNavigating) {
          _isNavigating = true;
          context.go('/login');
          debugPrint('ProfileSetupScreen: Issued navigation to /login from _savePreferences.');
        }
      }
      setState(() { _isLoading = false; });
      return; // Exit if no user
    }
    debugPrint('ProfileSetupScreen: Current user ID: ${currentUser.id}');

    final profileService = Provider.of<ProfileService>(context, listen: false);
    String? uploadedPhotoPath;

    debugPrint('ProfileSetupScreen: Checking for picked image...');
    if (_pickedImage != null) {
      debugPrint('ProfileSetupScreen: Image picked, attempting to upload analysis photo...');
      try {
        uploadedPhotoPath = await profileService.uploadAnalysisPhoto(currentUser.id, _pickedImage!.path);
        if (uploadedPhotoPath == null) {
          debugPrint('ProfileSetupScreen: Failed to get uploaded photo path from service.');
          throw Exception('Failed to get uploaded photo path after upload.');
        }
        debugPrint('ProfileSetupScreen: Analysis photo uploaded successfully. Path: $uploadedPhotoPath');
      } catch (e) {
        debugPrint('ProfileSetupScreen: Error uploading photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo for analysis: ${e.toString()}')),
          );
        }
        setState(() { _isLoading = false; });
        return; // Exit if photo upload fails
      }
    } else if (_imagePreviewPath != null && _imagePreviewPath!.startsWith('http')) {
      uploadedPhotoPath = _imagePreviewPath;
      debugPrint('ProfileSetupScreen: Using existing image preview path: $uploadedPhotoPath');
    } else {
      debugPrint('ProfileSetupScreen: No new image picked and no existing URL, continuing without photo upload.');
      uploadedPhotoPath = null;
    }

    try {
      debugPrint('ProfileSetupScreen: Attempting to save profile data to Supabase.');
      final UserProfile? existingProfile = profileService.userProfile;
      debugPrint('ProfileSetupScreen: Existing profile status: ${existingProfile != null ? 'Found' : 'Not Found'}');

      if (existingProfile == null) {
        debugPrint('ProfileSetupScreen: Creating new user profile...');
        final UserProfile newProfile = UserProfile(
          id: currentUser.id,
          email: currentUser.email!,
          createdAt: DateTime.now(),
          fullLegalName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
          displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
          profilePictureUrl: uploadedPhotoPath,
          dateOfBirth: _dateOfBirth,
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
          locationZipCode: _addressZipController.text.trim().isNotEmpty ? _addressZipController.text.trim() : null,
          genderIdentity: _gender,
          sexualOrientation: _sexualOrientation,
          heightCm: double.tryParse(_heightController.text.trim()),
          hobbiesAndInterests: _selectedInterests,
          lookingFor: _lookingFor,
          isPhase1Complete: true, // Mark Phase 1 as complete
          agreedToTerms: _agreedToTerms,
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          isPhase2Complete: false, // Ensure Phase 2 is false for new profiles here

          // Default values for other fields to satisfy the constructor
          ethnicity: null, languagesSpoken: const [], educationLevel: null,
          desiredOccupation: null, loveLanguages: const [], favoriteMedia: const [],
          maritalStatus: null, hasChildren: null, wantsChildren: null,
          willingToRelocate: null, monogamyVsPolyamoryPreferences: null,
          relationshipGoals: null, dealbreakers: const [], astrologicalSign: null,
          attachmentStyle: null, communicationStyle: null, mentalHealthDisclosures: null,
          petOwnership: null, travelFrequencyOrFavoriteDestinations: null,
          politicalViews: null, religionOrSpiritualBeliefs: null, diet: null,
          smokingHabits: null, drinkingHabits: null, sleepSchedule: null,
          questionnaireAnswers: const {}, personalityAssessmentResults: const {},
          profileVisibilityPreferences: const {}, pushNotificationPreferences: const {},
          addressZip: null, gender: null, height: null, interests: null,
          governmentIdFrontUrl: null, governmentIdBackUrl: null, fullName: null,
          hobbiesAndInterestsNew: null, loveLanguagesNew: null,
          locationCity: null, locationState: null,
        );
        debugPrint('ProfileSetupScreen: Calling profileService.insertProfile...');
        await profileService.insertProfile(newProfile);
        debugPrint('ProfileSetupScreen: User profile ${currentUser.id} inserted successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
        }
      } else {
        debugPrint('ProfileSetupScreen: Updating existing user profile...');
        final UserProfile updatedProfile = existingProfile.copyWith(
          updatedAt: DateTime.now(),
          fullLegalName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : existingProfile.fullLegalName,
          displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : existingProfile.displayName,
          profilePictureUrl: uploadedPhotoPath ?? existingProfile.profilePictureUrl,
          dateOfBirth: _dateOfBirth ?? existingProfile.dateOfBirth,
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : existingProfile.phoneNumber,
          locationZipCode: _addressZipController.text.trim().isNotEmpty ? _addressZipController.text.trim() : existingProfile.locationZipCode,
          genderIdentity: _gender ?? existingProfile.genderIdentity,
          sexualOrientation: _sexualOrientation ?? existingProfile.sexualOrientation,
          heightCm: double.tryParse(_heightController.text.trim()) ?? existingProfile.heightCm,
          hobbiesAndInterests: _selectedInterests,
          lookingFor: _lookingFor ?? existingProfile.lookingFor,
          isPhase1Complete: true, // Ensure Phase 1 is marked as complete
          agreedToTerms: _agreedToTerms,
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : existingProfile.bio,
          // isPhase2Complete: existingProfile.isPhase2Complete, // Keep existing Phase 2 status
        );
        debugPrint('ProfileSetupScreen: Calling profileService.updateProfile...');
        await profileService.updateProfile(profile: updatedProfile);
        debugPrint('ProfileSetupScreen: User profile ${currentUser.id} updated successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }

      // NAVIGATE TO DASHBOARD AFTER SUCCESSFUL PHASE 1 COMPLETION
      // Ensure the ProfileService state is updated to reflect Phase 1 completion
      // This will trigger the refreshListenable in main.dart's GoRouter
      debugPrint('ProfileSetupScreen: Re-initializing ProfileService to trigger GoRouter refresh...');
      await profileService.initializeProfile(); // Explicitly re-fetch and update profile state
      debugPrint('ProfileSetupScreen: ProfileService re-initialized. Current isPhase1Complete: ${profileService.userProfile?.isPhase1Complete}');

      if (mounted) {
        debugPrint('ProfileSetupScreen: About to issue navigation command to /dashboard-overview.');
        // Prevent multiple navigations
        if (!_isNavigating) {
          _isNavigating = true; // Set flag
          context.go('/dashboard-overview');
          debugPrint('ProfileSetupScreen: Navigation command issued for /dashboard-overview.');
        } else {
          debugPrint('ProfileSetupScreen: Navigation already in progress, skipping duplicate.');
        }
      } else {
        debugPrint('ProfileSetupScreen: Widget unmounted, cannot navigate after profile save.');
      }
    } on PostgrestException catch (e) {
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error saving profile data: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('ProfileSetupScreen: Generic Error saving profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile data: ${e.toString()}')),
        );
      }
    } finally {
      debugPrint('ProfileSetupScreen: _savePreferences finally block reached.');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _isNavigating = false; // Reset navigation flag
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color accentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color iconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (isDarkMode ? Colors.deepPurple.shade900 : Colors.blue.shade900).withOpacity(0.7),
                    (isDarkMode ? Colors.black : Colors.blue.shade500).withOpacity(0.85),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Complete Your Profile',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: textColor),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                tabs: _profileTabs,
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
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BasicInfoForm(
                        formKey: _formKeys[0],
                        fullNameController: _fullNameController,
                        displayNameController: _displayNameController,
                        heightController: _heightController,
                        onDateOfBirthSelected: _onDateOfBirthSelected,
                        onGenderChanged: _onGenderChanged,
                        dateOfBirth: _dateOfBirth,
                        gender: _gender,
                      ),
                      IdentityIDForm(
                        formKey: _formKeys[1],
                        onImagePicked: _onImagePicked,
                        phoneNumberController: _phoneNumberController,
                        addressZipController: _addressZipController,
                        imagePreviewPath: _imagePreviewPath,
                        pickedImageFile: _pickedImage,
                      ),
                      PreferencesForm(
                        formKey: _formKeys[2],
                        bioController: _bioController,
                        onSexualOrientationChanged: _onSexualOrientationChanged,
                        onLookingForChanged: _onLookingForChanged,
                        onInterestSelected: _onInterestSelected,
                        onInterestDeselected: _onInterestDeselected,
                        sexualOrientation: _sexualOrientation,
                        lookingFor: _lookingFor,
                        selectedInterests: _selectedInterests,
                        onMaritalStatusChanged: _onMaritalStatusChanged,
                      ),
                      ConsentForm(
                        formKey: _formKeys[3],
                        agreedToTerms: _agreedToTerms,
                        agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
                        onTermsChanged: _onTermsChanged,
                        onCommunityGuidelinesChanged: _onCommunityGuidelinesChanged,
                      ),
                    ],
                  ),
            bottomNavigationBar: BottomAppBar(
              color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_tabController.index == _profileTabs.length - 1) {
                      debugPrint('ProfileSetupScreen: "Complete Profile" button pressed.');
                      _savePreferences();
                    } else {
                      debugPrint('ProfileSetupScreen: "Next" button pressed. Current tab index: ${_tabController.index}');
                      if (_formKeys[_tabController.index].currentState!.validate()) {
                        debugPrint('ProfileSetupScreen: Current form validation successful. Moving to next tab.');
                        _tabController.animateTo(_tabController.index + 1);
                      } else {
                        debugPrint('ProfileSetupScreen: Current form validation failed.');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill out all required fields on this tab.')),
                          );
                        }
                      }
                    }
                  },
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
                      : Text(
                          _tabController.index == _profileTabs.length - 1 ? 'Complete Profile' : 'Next',
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}