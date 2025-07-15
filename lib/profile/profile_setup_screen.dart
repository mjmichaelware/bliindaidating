// lib/profile/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Ensure UserProfile is imported
import 'package:bliindaidating/services/profile_service.dart'; // Ensure ProfileService is imported
import 'package:bliindaidating/app_constants.dart'; // Ensure AppConstants is imported
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:cross_file/cross_file.dart'; // Import XFile
import 'package:image_picker/image_picker.dart'; // Corrected import for ImagePicker
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io'; // For File, if needed for platform-specific image handling

// Import custom background/effects for immersion (assuming these exist from your base project)
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

// Import the modular form widgets (CORRECTED PATHS)
import 'package:bliindaidating/screens/profile_setup/widgets/basic_info_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/identity_id_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/preferences_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/consent_form.dart';

// ... rest of your file remains the same as previously corrected ...

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  bool _isLoading = true;

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
  bool _showExerciseFrequency = false;
  bool _showSleepSchedule = false;
  bool _showPersonalityTraits = false;


  static const List<Tab> _profileTabs = <Tab>[
    Tab(text: 'Basic Info', icon: Icon(Icons.person)),
    Tab(text: 'Identity & Connection', icon: Icon(Icons.perm_identity)),
    Tab(text: 'Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Consent', icon: Icon(Icons.policy)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _profileTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPreferences();
  }

  @override
  void dispose() {
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
    setState(() {});
  }

  void _onImagePicked(XFile? image) {
    setState(() {
      _pickedImage = image;
      _imagePreviewPath = image?.path;
    });
  }

  void _onDateOfBirthSelected(DateTime? newDate) {
    setState(() {
      _dateOfBirth = newDate;
    });
  }

  void _onGenderChanged(String? newGender) {
    setState(() {
      _gender = newGender;
    });
  }

  void _onSexualOrientationChanged(String? newSexualOrientation) {
    setState(() {
      _sexualOrientation = newSexualOrientation;
    });
  }

  void _onLookingForChanged(String? newLookingFor) {
    setState(() {
      _lookingFor = newLookingFor;
    });
  }

  void _onInterestSelected(String interest) {
    setState(() {
      if (!_selectedInterests.contains(interest)) {
        _selectedInterests.add(interest);
      }
    });
  }

  void _onInterestDeselected(String interest) {
    setState(() {
      _selectedInterests.remove(interest);
    });
  }

  void _onTermsChanged(bool? value) {
    setState(() {
      _agreedToTerms = value ?? false;
    });
  }

  void _onCommunityGuidelinesChanged(bool? value) {
    setState(() {
      _agreedToCommunityGuidelines = value ?? false;
    });
  }

  // Dummy callback for onMaritalStatusChanged to satisfy PreferencesForm requirement
  void _onMaritalStatusChanged(String? newMaritalStatus) {
    // This function can remain empty or log the change if needed for debugging
    debugPrint('Marital Status changed to: $newMaritalStatus');
    // If you ever need to store this, add a state variable like _maritalStatus
    // setState(() { _maritalStatus = newMaritalStatus; });
  }


  Future<void> _loadPreferences() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        debugPrint('ProfileSetupScreen: No current user, redirecting to login.');
        context.go('/login');
      }
      return;
    }

    // Access ProfileService via Provider
    final profileService = Provider.of<ProfileService>(context, listen: false);

    try {
      final UserProfile? userProfile = await profileService.fetchUserProfile(id: currentUser.id);
      if (userProfile != null) {
        // Load data from the new fields first, then fallback to old ones if necessary for migration
        _fullNameController.text = userProfile.fullLegalName ?? userProfile.fullName ?? '';
        _displayNameController.text = userProfile.displayName ?? '';
        _heightController.text = userProfile.heightCm?.toString() ?? userProfile.height?.toString() ?? '';
        _phoneNumberController.text = userProfile.phoneNumber ?? '';
        // Only use locationZipCode, as locationCity/State are not desired
        _addressZipController.text = userProfile.locationZipCode ?? userProfile.addressZip ?? '';
        _bioController.text = userProfile.bio ?? '';

        _dateOfBirth = userProfile.dateOfBirth;
        _gender = userProfile.genderIdentity ?? userProfile.gender; // Prioritize new field
        _sexualOrientation = userProfile.sexualOrientation;
        _lookingFor = userProfile.lookingFor;
        // Directly use hobbiesAndInterests as it's the List<String> field
        _selectedInterests = List.from(userProfile.hobbiesAndInterests);
        _agreedToTerms = userProfile.agreedToTerms;
        _agreedToCommunityGuidelines = userProfile.agreedToCommunityGuidelines;
        _imagePreviewPath = userProfile.profilePictureUrl;

        _preferredGender = userProfile.genderIdentity ?? userProfile.gender; // Use new field
        _ageRange = const RangeValues(18, 50); // These are preferences, not directly from profile
        _maxDistance = 100; // These are preferences, not directly from profile

        // Assuming visibility flags might come from new profile fields if relevant
        _showFullName = userProfile.fullLegalName != null || userProfile.fullName != null;
        _showDisplayName = userProfile.displayName != null;
        _showAge = userProfile.dateOfBirth != null;
        _showGender = userProfile.genderIdentity != null || userProfile.gender != null;
        _showBio = userProfile.bio != null;
        _showSexualOrientation = userProfile.sexualOrientation != null;
        _showHeight = userProfile.heightCm != null || userProfile.height != null;
        // Check hobbiesAndInterests.isNotEmpty OR interests string is not empty
        _showInterests = userProfile.hobbiesAndInterests.isNotEmpty || (userProfile.interests?.isNotEmpty ?? false);
        _showLookingFor = userProfile.lookingFor != null;
        _showLocation = userProfile.locationZipCode != null || userProfile.addressZip != null;
        _showEthnicity = userProfile.ethnicity != null; // NEW: check for ethnicity
        // Directly use .isNotEmpty as these are List<String> fields
        _showLanguagesSpoken = userProfile.languagesSpoken.isNotEmpty;
        _showEducationLevel = userProfile.educationLevel != null; // NEW
        _showDesiredOccupation = userProfile.desiredOccupation != null; // NEW
        // Directly use .isNotEmpty as these are List<String> fields
        _showLoveLanguages = userProfile.loveLanguages.isNotEmpty;
        // Directly use .isNotEmpty as these are List<String> fields
        _showFavoriteMedia = userProfile.favoriteMedia.isNotEmpty;
        _showMaritalStatus = userProfile.maritalStatus != null; // NEW
        _showChildrenPreference = userProfile.hasChildren != null || userProfile.wantsChildren != null; // NEW
        _showWillingToRelocate = userProfile.willingToRelocate != null; // NEW
        _showMonogamyPolyamory = userProfile.monogamyVsPolyamoryPreferences != null; // NEW
        _showLoveRelationshipGoals = userProfile.relationshipGoals != null; // NEW
        // Directly use .isNotEmpty as these are List<String> fields
        _showDealbreakersBoundaries = userProfile.dealbreakers.isNotEmpty;
        _showAstrologicalSign = userProfile.astrologicalSign != null; // NEW
        _showAttachmentStyle = userProfile.attachmentStyle != null; // NEW
        _showCommunicationStyle = userProfile.communicationStyle != null; // NEW
        _showMentalHealthDisclosures = userProfile.mentalHealthDisclosures != null; // NEW
        _showPetOwnership = userProfile.petOwnership != null; // NEW
        _showTravelFrequencyDestinations = userProfile.travelFrequencyOrFavoriteDestinations != null; // NEW
        _showPoliticalViews = userProfile.politicalViews != null; // NEW
        _showReligionBeliefs = userProfile.religionOrSpiritualBeliefs != null; // NEW
        _showDiet = userProfile.diet != null; // NEW
        _showSmokingHabits = userProfile.smokingHabits != null; // NEW
        _showDrinkingHabits = userProfile.drinkingHabits != null; // NEW
        _showExerciseFrequency = userProfile.exerciseFrequencyOrFitnessLevel != null; // NEW
        _showSleepSchedule = userProfile.sleepSchedule != null; // NEW
        // Directly use .isNotEmpty as these are List<String> fields
        _showPersonalityTraits = userProfile.personalityTraits.isNotEmpty;

      }
      debugPrint('ProfileSetupScreen: Preferences loaded.');
    } catch (e) {
      debugPrint('ProfileSetupScreen: Error loading preferences: $e');
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
      debugPrint('ProfileSetupScreen: Validation failed for current tab.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields on this tab.')),
        );
      }
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

    // Access ProfileService via Provider
    final profileService = Provider.of<ProfileService>(context, listen: false);

    String? uploadedPhotoPath;
    if (_pickedImage != null) {
      try {
        // Assert _pickedImage is not null with '!'
        uploadedPhotoPath = await profileService.uploadAnalysisPhoto(currentUser.id, _pickedImage!.path);
        if (uploadedPhotoPath == null) {
          throw Exception('Failed to get uploaded photo path after upload.');
        }
      } catch (e) {
        debugPrint('ProfileSetupScreen: Error uploading photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo for analysis: ${e.toString()}')),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }
    } else if (_imagePreviewPath != null && _imagePreviewPath!.startsWith('http')) {
      // If no new image picked but there's an existing URL, retain it.
      uploadedPhotoPath = _imagePreviewPath;
    } else {
      debugPrint('ProfileSetupScreen: No analysis photo provided, continuing without upload.');
      uploadedPhotoPath = null; // Explicitly set to null if no image is present/uploaded
    }

    try {
      // Get existing profile to carry over non-updated fields
      // This is crucial for update, as partial updates only send changed fields.
      // We'll use the profileService.userProfile which should be pre-loaded by fetchUserProfile.
      final UserProfile? existingProfile = profileService.userProfile;

      // Determine if it's an insert or update operation
      if (existingProfile == null) {
        // INSERT SCENARIO
        final UserProfile newProfile = UserProfile(
          id: currentUser.id,
          email: currentUser.email!,
          createdAt: DateTime.now(), // FIX: Provide the createdAt timestamp
          fullLegalName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
          displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
          profilePictureUrl: uploadedPhotoPath,
          dateOfBirth: _dateOfBirth,
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
          locationZipCode: _addressZipController.text.trim().isNotEmpty ? _addressZipController.text.trim() : null,
          genderIdentity: _gender,
          sexualOrientation: _sexualOrientation,
          heightCm: double.tryParse(_heightController.text.trim()),
          hobbiesAndInterests: _selectedInterests, // Use directly, it's a List<String>
          lookingFor: _lookingFor,
          isPhase1Complete: true, // Mark Phase 1 complete upon successful initial setup
          agreedToTerms: _agreedToTerms,
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          isPhase2Complete: false, // Default to false for new profile

          // Ensure all other required fields for UserProfile are provided or have sensible defaults.
          // Your UserProfile constructor has default values for many List<String> and Map fields,
          // so explicitly setting them to `const []` or `const {}` is good for clarity,
          // but if the constructor defaults handle `null`, you might omit them if you're sure.
          // For simplicity and safety, I'm keeping them explicit here based on your provided model structure.
          ethnicity: null,
          languagesSpoken: const [],
          educationLevel: null,
          desiredOccupation: null,
          loveLanguages: const [],
          favoriteMedia: const [],
          maritalStatus: null,
          hasChildren: null,
          wantsChildren: null,
          willingToRelocate: null,
          monogamyVsPolyamoryPreferences: null,
          relationshipGoals: null,
          dealbreakers: const [],
          astrologicalSign: null,
          attachmentStyle: null,
          communicationStyle: null,
          mentalHealthDisclosures: null,
          petOwnership: null,
          travelFrequencyOrFavoriteDestinations: null,
          politicalViews: null,
          religionOrSpiritualBeliefs: null,
          diet: null,
          smokingHabits: null,
          drinkingHabits: null,
          exerciseFrequencyOrFitnessLevel: null,
          sleepSchedule: null,
          personalityTraits: const [],
          questionnaireAnswers: const {},
          personalityAssessmentResults: const {},
          profileVisibilityPreferences: const {}, // Ensure this is not null if required
          pushNotificationPreferences: const {}, // Ensure this is not null if required

          // Deprecated fields should generally not be set for new profiles unless specifically for migration logic
          addressZip: null,
          gender: null,
          height: null,
          interests: null,
          governmentIdFrontUrl: null,
          governmentIdBackUrl: null,
          fullName: null,
          hobbiesAndInterestsNew: null,
          loveLanguagesNew: null,
          locationCity: null,
          locationState: null,
        );
        await profileService.insertProfile(newProfile);
        debugPrint('User profile ${currentUser.id} inserted successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
        }
      } else {
        // UPDATE SCENARIO
        // Create a new UserProfile object using copyWith,
        // updating only the fields that are modified by this screen.
        final UserProfile updatedProfile = existingProfile.copyWith(
          // For update, createdAt should not be changed, it's the creation timestamp.
          // It's implicitly carried over by copyWith if not provided here.
          // However, if you have an 'updatedAt' field, you might want to set that:
          updatedAt: DateTime.now(), // Consider adding an `updatedAt` field update here

          fullLegalName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : existingProfile.fullLegalName,
          displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : existingProfile.displayName,
          profilePictureUrl: uploadedPhotoPath ?? existingProfile.profilePictureUrl, // Update if new path, otherwise keep existing
          dateOfBirth: _dateOfBirth ?? existingProfile.dateOfBirth,
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : existingProfile.phoneNumber,
          locationZipCode: _addressZipController.text.trim().isNotEmpty ? _addressZipController.text.trim() : existingProfile.locationZipCode,
          genderIdentity: _gender ?? existingProfile.genderIdentity,
          sexualOrientation: _sexualOrientation ?? existingProfile.sexualOrientation,
          heightCm: double.tryParse(_heightController.text.trim()) ?? existingProfile.heightCm,
          hobbiesAndInterests: _selectedInterests, // This will replace the entire list
          lookingFor: _lookingFor ?? existingProfile.lookingFor,
          isPhase1Complete: true, // Ensure this is true after completing this setup phase
          agreedToTerms: _agreedToTerms, // CORRECTED LINE
          agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : existingProfile.bio,
          // Other fields are implicitly carried over by copyWith if not explicitly set here.
          // Ensure that if a field can be "cleared" by user input (e.g., text field becoming empty),
          // you explicitly set it to `null` or an empty string/list if that's the desired behavior.
          // For text fields, `_controller.text.trim().isNotEmpty ? _controller.text.trim() : null` handles clearing.
        );
        // CORRECTED LINE: Use named argument 'profile'
        await profileService.updateProfile(profile: updatedProfile);
        debugPrint('User profile ${currentUser.id} updated successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }

      if (mounted) {
        // After initial setup, go to home or directly to Phase 2 onboarding
        context.go('/home'); // Or context.go('/phase2_onboarding_screen');
      }
    } on PostgrestException catch (e) {
      debugPrint('ProfileSetupScreen: Supabase Postgrest Error saving profile data: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('ProfileSetupScreen: Error saving profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    // final colorScheme = Theme.of(context).colorScheme; // Not used directly, can remove if not needed

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color accentColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor; // Using secondary as accent
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color iconColor = isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor; // Using AppConstants for consistency

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
          // Content on top of the background
          Scaffold(
            backgroundColor: Colors.transparent, // Make Scaffold transparent to show Stack background
            appBar: AppBar(
              title: Text(
                'Complete Your Profile',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: textColor),
              ),
              backgroundColor: Colors.transparent, // Transparent AppBar
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
                    physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
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
                        pickedImageFile: _pickedImage, // Pass the picked XFile for display
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
                        onMaritalStatusChanged: _onMaritalStatusChanged, // Added this line
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
                    // If it's the last tab, save preferences, otherwise go to next tab
                    if (_tabController.index == _profileTabs.length - 1) {
                      _savePreferences();
                    } else {
                      // Validate current tab before moving to the next
                      if (_formKeys[_tabController.index].currentState!.validate()) {
                        _tabController.animateTo(_tabController.index + 1);
                      } else {
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