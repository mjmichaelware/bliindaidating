// lib/screens/profile_setup/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

// Local Imports
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/animated_orb_background.dart';

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

  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (index) => GlobalKey<FormState>());

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _sexualOrientation;
  String? _lookingFor;
  Map<String, dynamic> _selectedInterests = {};
  bool _agreedToTerms = false;
  bool _agreedToCommunityGuidelines = false;
  XFile? _pickedImage;
  String? _imagePreviewPath;
  String? _maritalStatus;
  String? _ethnicity;

  bool _isLoading = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileSetupScreen: initState called.');
    _tabController = TabController(length: _profileTabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

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
    }
  }

  void _onImagePicked(XFile? image) {
    debugPrint('ProfileSetupScreen: _onImagePicked called with image: ${image?.path}.');
    setState(() {
      _pickedImage = image;
      _imagePreviewPath = image?.path;
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
      _selectedInterests[interest] = true;
      debugPrint('ProfileSetupScreen: Added interest "$interest" to _selectedInterests map.');
    });
  }

  void _onInterestDeselected(String interest) {
    debugPrint('ProfileSetupScreen: _onInterestDeselected called with interest: $interest.');
    setState(() {
      _selectedInterests.remove(interest);
      debugPrint('ProfileSetupScreen: Removed interest "$interest" from _selectedInterests map.');
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
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        debugPrint('ProfileSetupScreen: _isNavigating set to true. Redirecting to /login.');
        context.go('/login');
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final profileService = Provider.of<ProfileService>(context, listen: false);
    debugPrint('ProfileSetupScreen: ProfileService obtained from Provider.');

    try {
      debugPrint('ProfileSetupScreen: Attempting to fetch user profile for ID: ${currentUser.id}.');
      final UserProfile? userProfile = await profileService.fetchUserProfile(id: currentUser.id);
      debugPrint('ProfileSetupScreen: User profile fetch completed. Profile found: ${userProfile != null}.');

      // The crucial fix: Immediately check for a complete profile and redirect
      if (userProfile != null && userProfile.isPhase1Complete) {
        debugPrint('ProfileSetupScreen: Profile is already complete. Redirecting to dashboard.');
        if (mounted && !_isNavigating) {
          _isNavigating = true;
          context.go('/dashboard-overview');
        }
        setState(() { _isLoading = false; });
        return;
      }

      if (userProfile != null) {
        debugPrint('ProfileSetupScreen: User profile fetched. Populating fields from existing profile.');
        _fullNameController.text = userProfile.fullLegalName ?? '';
        _displayNameController.text = userProfile.displayName ?? '';
        _heightController.text = userProfile.heightCm?.toString() ?? '';
        _phoneNumberController.text = userProfile.phoneNumber ?? '';
        _addressZipController.text = userProfile.locationZipCode ?? '';
        _bioController.text = userProfile.bio ?? '';

        _dateOfBirth = userProfile.dateOfBirth;
        _gender = userProfile.genderIdentity;
        _sexualOrientation = userProfile.sexualOrientation;
        _lookingFor = userProfile.lookingFor;
        _selectedInterests = userProfile.hobbiesAndInterests ?? {};
        _agreedToTerms = userProfile.agreedToTerms;
        _agreedToCommunityGuidelines = userProfile.agreedToCommunityGuidelines;
        _imagePreviewPath = userProfile.profilePictureUrl;

        _maritalStatus = userProfile.maritalStatus;
        _ethnicity = userProfile.ethnicity;
        
        debugPrint('ProfileSetupScreen: Fields populated from existing profile data.');
        if (mounted) {
          setState(() {});
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

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('ProfileSetupScreen: No current user found for saving. Displaying error and redirecting to login.');
      if (mounted && !_isNavigating) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        _isNavigating = true;
        context.go('/login');
      }
      setState(() { _isLoading = false; });
      _isNavigating = false;
      return;
    }
    debugPrint('ProfileSetupScreen: Current user ID: ${currentUser.id}. Email: ${currentUser.email ?? "N/A"}.');

    final profileService = Provider.of<ProfileService>(context, listen: false);
    String? uploadedPhotoPath;

    if (_pickedImage != null) {
      debugPrint('ProfileSetupScreen: Image picked, attempting to upload analysis photo from path: ${_pickedImage!.path}.');
      try {
        uploadedPhotoPath = await profileService.uploadAnalysisPhoto(currentUser.id, _pickedImage!.path);
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
        setState(() { _isLoading = false; });
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

    try {
      debugPrint('ProfileSetupScreen: Attempting to save profile data to Supabase database.');
      // 1. Fetch the user profile directly from the database to check if it exists
      final UserProfile? existingProfile = await profileService.fetchUserProfile(id: currentUser.id);

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
          maritalStatus: _maritalStatus,
          ethnicity: _ethnicity,
          isPhase2Complete: false,

          // Default values for other nullable fields
          languagesSpoken: const [],
          educationLevel: null,
          desiredOccupation: null,
          loveLanguages: {},
          favoriteMedia: {},
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
          sleepSchedule: null,
          questionnaireAnswers: {},
          personalityAssessmentResults: {},
          profileVisibilityPreferences: {},
          pushNotificationPreferences: {},
          datingPreferences: {},
        );
        debugPrint('ProfileSetupScreen: New UserProfile object created. Calling profileService.insertProfile for ID: ${newProfile.id}.');
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
          maritalStatus: _maritalStatus ?? existingProfile.maritalStatus,
          ethnicity: _ethnicity ?? existingProfile.ethnicity,
        );
        debugPrint('ProfileSetupScreen: Updated UserProfile object created. Calling profileService.updateProfile for ID: ${updatedProfile.id}.');
        await profileService.updateProfile(profile: updatedProfile);
        debugPrint('ProfileSetupScreen: User profile ${currentUser.id} UPDATED successfully in Supabase.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }

      debugPrint('ProfileSetupScreen: Profile saved successfully. Re-initializing ProfileService and navigating to dashboard.');
      await profileService.initializeProfile();

      if (mounted && !_isNavigating) {
        _isNavigating = true;
        debugPrint('ProfileSetupScreen: _isNavigating set to true. Calling context.go(/dashboard-overview).');
        context.go('/dashboard-overview');
        return;
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
          const AnimatedOrbBackground(),
          TabBarView(
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
                selectedInterests: _selectedInterests.keys.toList(),
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
