import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // Required for File

// Local Imports
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/controllers/theme_controller.dart'; // Ensure this is imported
import 'package:bliindaidating/widgets/animated_orb_background.dart'; // Ensure this path is correct

// Form Widgets
import 'package:bliindaidating/screens/profile_setup/widgets/basic_info_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/identity_id_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/preferences_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/consent_form.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _profileTabs = const [
    Tab(text: 'Basic Info'),
    Tab(text: 'Identity & Contact'),
    Tab(text: 'Preferences'),
    Tab(text: 'Consent'),
  ];

  // Form Keys for validation per tab
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (index) => GlobalKey<FormState>());

  // Text Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // State Variables for Profile Fields
  DateTime? _dateOfBirth;
  String? _gender;
  String? _sexualOrientation;
  String? _lookingFor;
  List<String> _selectedInterests = [];
  bool _agreedToTerms = false;
  bool _agreedToCommunityGuidelines = false;
  XFile? _pickedImage; // For the newly picked image file
  String? _imagePreviewPath; // For displaying existing image from URL or new picked image
  String? _maritalStatus; // NEW: Marital Status
  String? _ethnicity; // NEW: Ethnicity

  // Placeholder for future use, remove if not needed for phase 1
  String? _preferredGender;

  // Visibility toggles (initialize to true or based on default profile setup)
  bool _showFullName = true;
  bool _showDisplayName = true;
  bool _showAge = true;
  bool _showGender = true;
  bool _showBio = true;
  bool _showSexualOrientation = true;
  bool _showHeight = true;
  bool _showInterests = true;
  bool _showLookingFor = true;
  bool _showLocation = true;
  bool _showEthnicity = true; // NEW
  bool _showLanguagesSpoken = true;
  bool _showEducationLevel = true;
  bool _showDesiredOccupation = true;
  bool _showLoveLanguages = true;
  bool _showFavoriteMedia = true;
  bool _showMaritalStatus = true; // NEW
  bool _showChildrenPreference = true;
  bool _showWillingToRelocate = true;
  bool _showMonogamyPolyamory = true;
  bool _showLoveRelationshipGoals = true;
  bool _showDealbreakersBoundaries = true;
  bool _showAstrologicalSign = true;
  bool _showAttachmentStyle = true;
  bool _showCommunicationStyle = true;
  bool _showMentalHealthDisclosures = true;
  bool _showPetOwnership = true;
  bool _showTravelFrequencyDestinations = true;
  bool _showPoliticalViews = true;
  bool _showReligionBeliefs = true;
  bool _showDiet = true;
  bool _showSmokingHabits = true;
  bool _showDrinkingHabits = true;
  bool _showSleepSchedule = true;

  // Loading state
  bool _isLoading = false;
  bool _isNavigating = false; // Flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileSetupScreen: initState called.');
    _tabController = TabController(length: _profileTabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Load preferences after the first frame to ensure context is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  @override
  void dispose() {
    debugPrint('ProfileSetupScreen: dispose called.');
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _heightController.dispose();
    _phoneNumberController.dispose();
    _addressZipController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      debugPrint('ProfileSetupScreen: Tab index is changing to ${_tabController.index}');
      // Optional: Add validation here before allowing tab change
      // if (!_formKeys[_tabController.previousIndex].currentState!.validate()) {
      //   // Prevent tab change if validation fails
      //   _tabController.index = _tabController.previousIndex;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please fill out all required fields on this tab before proceeding.')),
      //   );
      // }
    }
  }

  void _onImagePicked(XFile? image) {
    debugPrint('ProfileSetupScreen: _onImagePicked called with image: ${image?.path}.');
    setState(() {
      _pickedImage = image;
      // If a new image is picked, update the preview path to the new image's path
      _imagePreviewPath = image?.path; // Use path for XFile
      debugPrint('ProfileSetupScreen: _pickedImage and _imagePreviewPath updated.');
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
    setState(() {
      _maritalStatus = newMaritalStatus;
      debugPrint('ProfileSetupScreen: _maritalStatus updated to $_maritalStatus in setState.');
    });
  }

  void _onEthnicityChanged(String? newEthnicity) {
    debugPrint('ProfileSetupScreen: _onEthnicityChanged called with ethnicity: $newEthnicity.');
    setState(() {
      _ethnicity = newEthnicity;
      debugPrint('ProfileSetupScreen: _ethnicity updated to $_ethnicity in setState.');
    });
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

        _maritalStatus = userProfile.maritalStatus; // NEW: Populate marital status
        debugPrint('ProfileSetupScreen: Marital Status populated: "$_maritalStatus".');
        _ethnicity = userProfile.ethnicity; // NEW: Populate ethnicity
        debugPrint('ProfileSetupScreen: Ethnicity populated: "$_ethnicity".');

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

        if (mounted) {
          setState(() {
            debugPrint('ProfileSetupScreen: setState called after populating fields in _loadPreferences.');
          });
        }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          debugPrint('ProfileSetupScreen: _loadPreferences finally block executed. _isLoading set to false.');
        });
      }
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
      setState(() { _isLoading = false; });
      _isNavigating = false;
      return;
    }

    if (!currentFormKey.currentState!.validate()) {
      debugPrint('ProfileSetupScreen: Validation failed for current tab (index: ${_tabController.index}).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields on this tab.')),
        );
      }
      setState(() { _isLoading = false; });
      _isNavigating = false;
      return;
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
        _isLoading = false;
        debugPrint('ProfileSetupScreen: _isLoading set to false due to no current user (save scenario).');
      });
      _isNavigating = false;
      return;
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
          _isLoading = false;
          debugPrint('ProfileSetupScreen: _isLoading set to false after photo upload error.');
        });
        _isNavigating = false;
        return;
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
      final UserProfile? existingProfile = profileService.userProfile;
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
          isPhase1Complete: true,
          agreedToTerms: _agreedToTerms,
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          maritalStatus: _maritalStatus, // NEW
          ethnicity: _ethnicity, // NEW
          isPhase2Complete: false,

          // Default values for other fields to satisfy the constructor
          languagesSpoken: const [], educationLevel: null,
          desiredOccupation: null, loveLanguages: const [], favoriteMedia: const [],
          hasChildren: null, wantsChildren: null,
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
          isPhase1Complete: true,
          agreedToTerms: _agreedToTerms,
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : existingProfile.bio,
          maritalStatus: _maritalStatus ?? existingProfile.maritalStatus, // NEW
          ethnicity: _ethnicity ?? existingProfile.ethnicity, // NEW
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

      debugPrint('ProfileSetupScreen: Profile saved successfully. Initiating post-save actions.');
      debugPrint('ProfileSetupScreen: Re-initializing ProfileService to trigger GoRouter refresh mechanism.');
      debugPrint('ProfileSetupScreen: _savePreferences - Before calling profileService.initializeProfile.');
      await profileService.initializeProfile();
      debugPrint('ProfileSetupScreen: _savePreferences - After calling profileService.initializeProfile. ProfileService state updated.');
      debugPrint('ProfileSetupScreen: ProfileService re-initialized. Current isPhase1Complete: ${profileService.userProfile?.isPhase1Complete}.');

      if (mounted) {
        debugPrint('ProfileSetupScreen: Widget is mounted. Checking _isNavigating flag before GoRouter navigation.');
        debugPrint('ProfileSetupScreen: About to issue navigation command to /dashboard-overview.');
        debugPrint('ProfileSetupScreen: _savePreferences - Before GoRouter context.go navigation.');
        if (!_isNavigating) {
          _isNavigating = true;
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
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error occurred while saving profile data: CODE: ${e.code ?? "N/A"}, MESSAGE: ${e.message}.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ProfileSetupScreen: Generic Error occurred while saving profile data: ${e.toString()}. Stack: ${stackTrace}.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          debugPrint('ProfileSetupScreen: _savePreferences finally block reached. Resetting loading state.');
        });
      }
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _profileTabs,
        ),
      ),
      body: Stack(
        children: [
          const AnimatedOrbBackground(), // This will now resolve if file exists/is created
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BasicInfoForm(
                formKey: _formKeys[0], // CHANGED: 'key' to 'formKey'
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
                formKey: _formKeys[2], // Ensure this is also 'formKey'
                bioController: _bioController,
                onSexualOrientationChanged: _onSexualOrientationChanged,
                onLookingForChanged: _onLookingForChanged,
                onInterestSelected: _onInterestSelected,
                onInterestDeselected: _onInterestDeselected,
                sexualOrientation: _sexualOrientation,
                lookingFor: _lookingFor,
                selectedInterests: _selectedInterests,
                maritalStatus: _maritalStatus,
                onMaritalStatusChanged: _onMaritalStatusChanged,
                ethnicity: _ethnicity,
                onEthnicityChanged: _onEthnicityChanged,
              ),
              ConsentForm(
                formKey: _formKeys[3],
                agreedToTerms: _agreedToTerms,
                onTermsChanged: _onTermsChanged,
                agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
                onCommunityGuidelinesChanged: _onCommunityGuidelinesChanged,
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_tabController.index > 0)
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  setState(() {
                    _tabController.animateTo(_tabController.index - 1);
                  });
                },
                child: const Text('Back'),
              ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                if (_tabController.index < _profileTabs.length - 1) {
                  if (_formKeys[_tabController.index].currentState?.validate() ?? false) {
                    setState(() {
                      _tabController.animateTo(_tabController.index + 1);
                    });
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill out all required fields before proceeding.')),
                      );
                    }
                  }
                } else {
                  await _savePreferences();
                }
              },
              child: Text(_tabController.index == _profileTabs.length - 1
                  ? 'Finish Setup'
                  : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}
