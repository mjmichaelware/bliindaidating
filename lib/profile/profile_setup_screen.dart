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
    debugPrint('ProfileSetupScreen: TabController initialized and listener added.');
    _loadPreferences();
    debugPrint('ProfileSetupScreen: _loadPreferences called from initState.');
  }

  @override
  void dispose() {
    debugPrint('ProfileSetupScreen: dispose called. Disposing controllers and listeners.');
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _heightController.dispose();
    _phoneNumberController.dispose();
    _addressZipController.dispose();
    _bioController.dispose();
    debugPrint('ProfileSetupScreen: All controllers disposed.');
    super.dispose();
  }

  void _handleTabChange() {
    debugPrint('ProfileSetupScreen: Tab change listener fired. Tab index changed to ${_tabController.index}.');
    setState(() {
      debugPrint('ProfileSetupScreen: setState called from _handleTabChange.');
    });
  }

  void _onImagePicked(XFile? image) {
    debugPrint('ProfileSetupScreen: _onImagePicked called with image: ${image?.path ?? "null"}.');
    setState(() {
      _pickedImage = image;
      _imagePreviewPath = image?.path;
      debugPrint('ProfileSetupScreen: _pickedImage and _imagePreviewPath updated in setState for image pick.');
    });
  }

  void _onDateOfBirthSelected(DateTime? newDate) {
    debugPrint('ProfileSetupScreen: _onDateOfBirthSelected called with date: $newDate.');
    setState(() {
      _dateOfBirth = newDate;
      debugPrint('ProfileSetupScreen: _dateOfBirth updated in setState for date selection.');
    });
  }

  void _onGenderChanged(String? newGender) {
    debugPrint('ProfileSetupScreen: _onGenderChanged called with gender: $newGender.');
    setState(() {
      _gender = newGender;
      debugPrint('ProfileSetupScreen: _gender updated in setState for gender change.');
    });
  }

  void _onSexualOrientationChanged(String? newSexualOrientation) {
    debugPrint('ProfileSetupScreen: _onSexualOrientationChanged called with orientation: $newSexualOrientation.');
    setState(() {
      _sexualOrientation = newSexualOrientation;
      debugPrint('ProfileSetupScreen: _sexualOrientation updated in setState for orientation change.');
    });
  }

  void _onLookingForChanged(String? newLookingFor) {
    debugPrint('ProfileSetupScreen: _onLookingForChanged called with lookingFor: $newLookingFor.');
    setState(() {
      _lookingFor = newLookingFor;
      debugPrint('ProfileSetupScreen: _lookingFor updated in setState for lookingFor change.');
    });
  }

  void _onInterestSelected(String interest) {
    debugPrint('ProfileSetupScreen: _onInterestSelected called with interest: $interest.');
    setState(() {
      if (!_selectedInterests.contains(interest)) {
        _selectedInterests.add(interest);
        debugPrint('ProfileSetupScreen: Added interest "$interest" to _selectedInterests.');
      } else {
        debugPrint('ProfileSetupScreen: Interest "$interest" already exists, not adding.');
      }
    });
  }

  void _onInterestDeselected(String interest) {
    debugPrint('ProfileSetupScreen: _onInterestDeselected called with interest: $interest.');
    setState(() {
      _selectedInterests.remove(interest);
      debugPrint('ProfileSetupScreen: Removed interest "$interest" from _selectedInterests.');
    });
  }

  void _onTermsChanged(bool? value) {
    debugPrint('ProfileSetupScreen: _onTermsChanged called with value: $value.');
    setState(() {
      _agreedToTerms = value ?? false;
      debugPrint('ProfileSetupScreen: _agreedToTerms updated to $_agreedToTerms in setState.');
    });
  }

  void _onCommunityGuidelinesChanged(bool? value) {
    debugPrint('ProfileSetupScreen: _onCommunityGuidelinesChanged called with value: $value.');
    setState(() {
      _agreedToCommunityGuidelines = value ?? false;
      debugPrint('ProfileSetupScreen: _agreedToCommunityGuidelines updated to $_agreedToCommunityGuidelines in setState.');
    });
  }

  void _onMaritalStatusChanged(String? newMaritalStatus) {
    debugPrint('ProfileSetupScreen: _onMaritalStatusChanged called with status: $newMaritalStatus.');
    // No setState here, assuming this value is handled elsewhere or is a placeholder for future use.
  }


  Future<void> _loadPreferences() async {
    debugPrint('ProfileSetupScreen: _loadPreferences started.');
    setState(() {
      _isLoading = true;
      debugPrint('ProfileSetupScreen: _isLoading set to true at start of _loadPreferences.');
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('ProfileSetupScreen: Fetched currentUser: ${currentUser?.id ?? "null"}.');

    if (currentUser == null) {
      if (mounted) {
        debugPrint('ProfileSetupScreen: No current user during load, checking _isNavigating flag.');
        if (!_isNavigating) {
          _isNavigating = true; // Set flag
          debugPrint('ProfileSetupScreen: _isNavigating set to true. Redirecting to /login.');
          context.go('/login');
          debugPrint('ProfileSetupScreen: Issued navigation to /login from _loadPreferences.');
        } else {
          debugPrint('ProfileSetupScreen: Already navigating, skipping duplicate redirect to /login.');
        }
      } else {
        debugPrint('ProfileSetupScreen: Widget unmounted, cannot redirect to login from _loadPreferences.');
      }
      setState(() {
        _isLoading = false; // Ensure loading state is reset even on redirect
        debugPrint('ProfileSetupScreen: _isLoading set to false due to no current user (redirect scenario).');
      });
      return;
    }

    final profileService = Provider.of<ProfileService>(context, listen: false);
    debugPrint('ProfileSetupScreen: ProfileService obtained from Provider.');

    try {
      debugPrint('ProfileSetupScreen: Attempting to fetch user profile for ID: ${currentUser.id}.');
      final UserProfile? userProfile = await profileService.fetchUserProfile(id: currentUser.id);
      debugPrint('ProfileSetupScreen: User profile fetch completed. Profile found: ${userProfile != null}.');

      if (userProfile != null) {
        debugPrint('ProfileSetupScreen: User profile fetched. Populating fields from existing profile.');
        _fullNameController.text = userProfile.fullLegalName ?? userProfile.fullName ?? '';
        debugPrint('ProfileSetupScreen: Full Name populated: "${_fullNameController.text}".');
        _displayNameController.text = userProfile.displayName ?? '';
        debugPrint('ProfileSetupScreen: Display Name populated: "${_displayNameController.text}".');
        _heightController.text = userProfile.heightCm?.toString() ?? userProfile.height?.toString() ?? '';
        debugPrint('ProfileSetupScreen: Height populated: "${_heightController.text}".');
        _phoneNumberController.text = userProfile.phoneNumber ?? '';
        debugPrint('ProfileSetupScreen: Phone Number populated: "${_phoneNumberController.text}".');
        _addressZipController.text = userProfile.locationZipCode ?? userProfile.addressZip ?? '';
        debugPrint('ProfileSetupScreen: Address Zip populated: "${_addressZipController.text}".');
        _bioController.text = userProfile.bio ?? '';
        debugPrint('ProfileSetupScreen: Bio populated: "${_bioController.text}".');

        _dateOfBirth = userProfile.dateOfBirth;
        debugPrint('ProfileSetupScreen: Date of Birth populated: "$_dateOfBirth".');
        _gender = userProfile.genderIdentity ?? userProfile.gender;
        debugPrint('ProfileSetupScreen: Gender populated: "$_gender".');
        _sexualOrientation = userProfile.sexualOrientation;
        debugPrint('ProfileSetupScreen: Sexual Orientation populated: "$_sexualOrientation".');
        _lookingFor = userProfile.lookingFor;
        debugPrint('ProfileSetupScreen: Looking For populated: "$_lookingFor".');
        _selectedInterests = List.from(userProfile.hobbiesAndInterests);
        debugPrint('ProfileSetupScreen: Selected Interests populated: "$_selectedInterests".');
        _agreedToTerms = userProfile.agreedToTerms;
        debugPrint('ProfileSetupScreen: Agreed to Terms populated: "$_agreedToTerms".');
        _agreedToCommunityGuidelines = userProfile.agreedToCommunityGuidelines;
        debugPrint('ProfileSetupScreen: Agreed to Community Guidelines populated: "$_agreedToCommunityGuidelines".');
        _imagePreviewPath = userProfile.profilePictureUrl;
        debugPrint('ProfileSetupScreen: Image Preview Path populated: "$_imagePreviewPath".');

        _preferredGender = userProfile.genderIdentity ?? userProfile.gender;
        debugPrint('ProfileSetupScreen: Preferred Gender populated: "$_preferredGender".');

        // Visibility toggles - Populating these from profile data
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
        debugPrint('ProfileSetupScreen: Visibility toggles updated based on existing profile data.');

      } else {
        debugPrint('ProfileSetupScreen: No existing user profile found for ID: ${currentUser.id}. Initializing with default/empty values.');
      }
      debugPrint('ProfileSetupScreen: Preferences loading process completed successfully.');
    } on PostgrestException catch (e) {
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error during _loadPreferences: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('ProfileSetupScreen: Generic Error during _loadPreferences: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        debugPrint('ProfileSetupScreen: _loadPreferences finally block executed. _isLoading set to false.');
      });
    }
  }

  Future<void> _savePreferences() async {
    debugPrint('ProfileSetupScreen: _savePreferences started. (Entry Point)');

    debugPrint('ProfileSetupScreen: _savePreferences - Before initial form validation check for tab index ${_tabController.index}.');
    final currentFormKey = _formKeys[_tabController.index];
    if (currentFormKey.currentState == null) {
      debugPrint('ProfileSetupScreen: ERROR: currentFormKey.currentState is NULL for tab index ${_tabController.index}. Cannot validate.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Form state not available for validation.')),
        );
      }
      setState(() { _isLoading = false; }); // Ensure loading is off if a critical error occurs
      _isNavigating = false; // Reset navigation flag
      return;
    }

    if (!currentFormKey.currentState!.validate()) {
      debugPrint('ProfileSetupScreen: Validation failed for current tab (index: ${_tabController.index}).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields on this tab.')),
        );
      }
      setState(() { _isLoading = false; }); // Ensure loading is off if validation fails
      _isNavigating = false; // Reset navigation flag
      return; // Exit if validation fails
    }
    debugPrint('ProfileSetupScreen: _savePreferences - After initial form validation, validation successful.');

    setState(() {
      _isLoading = true;
      debugPrint('ProfileSetupScreen: _isLoading set to true at start of _savePreferences.');
    });

    debugPrint('ProfileSetupScreen: _savePreferences - Before getting Supabase current user.');
    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('ProfileSetupScreen: _savePreferences - After getting Supabase current user. User: ${currentUser?.id ?? "null"}.');

    if (currentUser == null) {
      debugPrint('ProfileSetupScreen: No current user found for saving. Displaying error and redirecting to login.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        // Prevent multiple navigations
        if (!_isNavigating) {
          _isNavigating = true;
          debugPrint('ProfileSetupScreen: _isNavigating set to true. Calling context.go(/login).');
          context.go('/login');
          debugPrint('ProfileSetupScreen: Issued navigation to /login from _savePreferences (no user).');
        } else {
          debugPrint('ProfileSetupScreen: Already navigating, skipping duplicate redirect to /login.');
        }
      } else {
        debugPrint('ProfileSetupScreen: Widget unmounted, cannot redirect to login from _savePreferences (no user).');
      }
      setState(() {
        _isLoading = false; // Ensure loading state is reset
        debugPrint('ProfileSetupScreen: _isLoading set to false due to no current user (save scenario).');
      });
      _isNavigating = false; // Reset navigation flag
      return; // Exit if no user
    }
    debugPrint('ProfileSetupScreen: Current user ID: ${currentUser.id}. Email: ${currentUser.email ?? "N/A"}.');

    debugPrint('ProfileSetupScreen: _savePreferences - Before getting ProfileService from Provider.');
    final profileService = Provider.of<ProfileService>(context, listen: false);
    debugPrint('ProfileSetupScreen: _savePreferences - After getting ProfileService.');

    String? uploadedPhotoPath;

    debugPrint('ProfileSetupScreen: Checking for picked image (_pickedImage: ${_pickedImage != null}).');
    debugPrint('ProfileSetupScreen: Existing image preview path (_imagePreviewPath: $_imagePreviewPath).');

    if (_pickedImage != null) {
      debugPrint('ProfileSetupScreen: Image picked, attempting to upload analysis photo from path: ${_pickedImage!.path}.');
      try {
        debugPrint('ProfileSetupScreen: _savePreferences - Calling profileService.uploadAnalysisPhoto.');
        uploadedPhotoPath = await profileService.uploadAnalysisPhoto(currentUser.id, _pickedImage!.path);
        debugPrint('ProfileSetupScreen: _savePreferences - After profileService.uploadAnalysisPhoto call. Uploaded path: $uploadedPhotoPath.');
        if (uploadedPhotoPath == null) {
          debugPrint('ProfileSetupScreen: Failed to get uploaded photo path from service. Upload analysis photo returned null.');
          throw Exception('Failed to get uploaded photo path after upload.');
        }
        debugPrint('ProfileSetupScreen: Analysis photo uploaded successfully. Final path: $uploadedPhotoPath');
      } catch (e) {
        debugPrint('ProfileSetupScreen: Error uploading photo for analysis: ${e.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo for analysis: ${e.toString()}')),
          );
        }
        setState(() {
          _isLoading = false; // Ensure loading is off if photo upload fails
          debugPrint('ProfileSetupScreen: _isLoading set to false after photo upload error.');
        });
        _isNavigating = false; // Reset navigation flag
        return; // Exit if photo upload fails
      }
    } else if (_imagePreviewPath != null && _imagePreviewPath!.startsWith('http')) {
      uploadedPhotoPath = _imagePreviewPath;
      debugPrint('ProfileSetupScreen: No new image picked. Using existing image preview path: $uploadedPhotoPath for profile.');
    } else {
      debugPrint('ProfileSetupScreen: No new image picked and no existing URL found. Continuing without photo upload.');
      uploadedPhotoPath = null;
    }
    debugPrint('ProfileSetupScreen: _savePreferences - After all image handling logic. Final uploadedPhotoPath: $uploadedPhotoPath.');


    try {
      debugPrint('ProfileSetupScreen: Attempting to save profile data to Supabase database.');
      debugPrint('ProfileSetupScreen: _savePreferences - Before fetching existing profile from ProfileService\'s internal state.');
      final UserProfile? existingProfile = profileService.userProfile; // This reads from ProfileService's internal state
      debugPrint('ProfileSetupScreen: Existing profile status: ${existingProfile != null ? 'Found' : 'Not Found'}.');
      debugPrint('ProfileSetupScreen: _savePreferences - After fetching existing profile, before insert/update decision.');

      if (existingProfile == null) {
        debugPrint('ProfileSetupScreen: Existing profile not found. Creating a NEW user profile for ${currentUser.id}.');
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
        debugPrint('ProfileSetupScreen: New UserProfile object created. Calling profileService.insertProfile for ID: ${newProfile.id}.');
        debugPrint('ProfileSetupScreen: New Profile Data: fullLegalName: ${newProfile.fullLegalName}, displayName: ${newProfile.displayName}, isPhase1Complete: ${newProfile.isPhase1Complete}');
        await profileService.insertProfile(newProfile);
        debugPrint('ProfileSetupScreen: User profile ${currentUser.id} INSERTED successfully into Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
        }
      } else {
        debugPrint('ProfileSetupScreen: Existing profile found. Updating user profile for ${currentUser.id}.');
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
        debugPrint('ProfileSetupScreen: Updated UserProfile object created. Calling profileService.updateProfile for ID: ${updatedProfile.id}.');
        debugPrint('ProfileSetupScreen: Updated Profile Data: fullLegalName: ${updatedProfile.fullLegalName}, displayName: ${updatedProfile.displayName}, isPhase1Complete: ${updatedProfile.isPhase1Complete}');
        await profileService.updateProfile(profile: updatedProfile);
        debugPrint('ProfileSetupScreen: User profile ${currentUser.id} UPDATED successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }

      // NAVIGATE TO DASHBOARD AFTER SUCCESSFUL PHASE 1 COMPLETION
      debugPrint('ProfileSetupScreen: Profile saved successfully. Initiating post-save actions.');
      debugPrint('ProfileSetupScreen: Re-initializing ProfileService to trigger GoRouter refresh mechanism.');
      debugPrint('ProfileSetupScreen: _savePreferences - Before calling profileService.initializeProfile.');
      await profileService.initializeProfile(); // Explicitly re-fetch and update profile state
      debugPrint('ProfileSetupScreen: _savePreferences - After calling profileService.initializeProfile. ProfileService state updated.');
      debugPrint('ProfileSetupScreen: ProfileService re-initialized. Current isPhase1Complete: ${profileService.userProfile?.isPhase1Complete}.');

      if (mounted) {
        debugPrint('ProfileSetupScreen: Widget is mounted. Checking _isNavigating flag before GoRouter navigation.');
        debugPrint('ProfileSetupScreen: About to issue navigation command to /dashboard-overview.');
        debugPrint('ProfileSetupScreen: _savePreferences - Before GoRouter context.go navigation.');
        if (!_isNavigating) {
          _isNavigating = true; // Set flag to prevent multiple navigations
          debugPrint('ProfileSetupScreen: _isNavigating set to true. Calling context.go(/dashboard-overview).');
          context.go('/dashboard-overview');
          debugPrint('ProfileSetupScreen: Navigation command issued for /dashboard-overview. Should now transition.');
        } else {
          debugPrint('ProfileSetupScreen: Navigation already in progress (flag _isNavigating is true), skipping duplicate navigation to /dashboard-overview.');
        }
      } else {
        debugPrint('ProfileSetupScreen: Widget unmounted, cannot perform navigation after profile save.');
      }
    } on PostgrestException catch (e) {
      // FIX APPLIED HERE: PostgrestException does not have a 'stackTrace' getter directly.
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error occurred while saving profile data: CODE: ${e.code ?? "N/A"}, MESSAGE: ${e.message}.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e, stackTrace) { // This generic catch correctly provides stackTrace
      debugPrint('ProfileSetupScreen: Generic Error occurred while saving profile data: ${e.toString()}. Stack: ${stackTrace}.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile data: ${e.toString()}')),
        );
      }
    } finally {
      debugPrint('ProfileSetupScreen: _savePreferences finally block reached. Resetting loading state and navigation flag.');
      debugPrint('ProfileSetupScreen: _savePreferences - Before setting _isLoading to false in finally block (mounted: $mounted).');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('ProfileSetupScreen: _isLoading set to false via setState in finally block.');
      } else {
        debugPrint('ProfileSetupScreen: Widget unmounted in finally block, cannot call setState to set _isLoading to false.');
      }
      _isNavigating = false; // Reset navigation flag
      debugPrint('ProfileSetupScreen: _savePreferences function finished execution.');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileSetupScreen: build method started.');
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    debugPrint('ProfileSetupScreen: Theme loaded. Dark Mode: $isDarkMode.');

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color accentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color iconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor;
    debugPrint('ProfileSetupScreen: Theme colors determined.');

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
                    debugPrint('ProfileSetupScreen: ElevatedButton onPressed handler activated. Current tab index: ${_tabController.index}.');
                    if (_tabController.index == _profileTabs.length - 1) {
                      debugPrint('ProfileSetupScreen: "Complete Profile" button pressed (last tab). Calling _savePreferences().');
                      _savePreferences();
                    } else {
                      debugPrint('ProfileSetupScreen: "Next" button pressed. Current tab index: ${_tabController.index}.');
                      // Validate the current form before moving to the next tab
                      final currentFormKey = _formKeys[_tabController.index];
                      if (currentFormKey.currentState == null) {
                        debugPrint('ProfileSetupScreen: ERROR: currentFormKey.currentState is NULL for "Next" button. Cannot validate.');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: Form state not available for validation on this tab.')),
                          );
                        }
                        return; // Exit if form state is null
                      }

                      if (currentFormKey.currentState!.validate()) {
                        debugPrint('ProfileSetupScreen: Current form validation successful. Moving to next tab (index: ${_tabController.index + 1}).');
                        _tabController.animateTo(_tabController.index + 1);
                      } else {
                        debugPrint('ProfileSetupScreen: Current form validation failed. Showing snackbar.');
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