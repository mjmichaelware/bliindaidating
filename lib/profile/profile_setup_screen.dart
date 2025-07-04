// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
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


// Import custom background/effects for immersion (assuming these exist from your base project)
import 'package:bliindaidating/landing_page/widgets/animated_orb_background.dart';

// Import the modular form widgets (assuming these exist from your base project)
import 'package:bliindaidating/screens/profile_setup/widgets/basic_info_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/identity_id_form.dart';
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
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;

  // --- Image Handling State ---
  XFile? _pickedImage; // Stores the XFile picked by the user
  String? _imagePreviewPath; // Stores the URL for network images or path for local preview

  // --- TextEditingControllers for form fields ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // --- Variables for dropdowns/pickers/checkboxes ---
  DateTime? _dateOfBirth;
  String? _gender;
  String? _sexualOrientation;
  String? _lookingFor;
  List<String> _selectedInterests = [];
  bool _agreedToTerms = false;
  bool _agreedToCommunityGuidelines = false;

  // --- Dating Preferences State (Already declared, good) ---
  String? _preferredGender;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 100; // in miles

  // --- Profile Visibility State (Already declared, good) ---
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


  // Tab Definitions (Order based on user's preference for progression)
  static const List<Tab> _profileTabs = <Tab>[
    Tab(text: 'Basic Info', icon: Icon(Icons.person)),
    Tab(text: 'Identity & Connection', icon: Icon(Icons.perm_identity)), // Icon changed for connection theme
    Tab(text: 'Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Consent', icon: Icon(Icons.policy)), // Icon changed for policy theme
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

  // --- Callbacks to update state from child forms ---
  void _onImagePicked(XFile? image) {
    setState(() {
      _pickedImage = image;
      // For display, use the XFile's path if it's a new pick, otherwise rely on imagePreviewPath for network images
      _imagePreviewPath = image?.path; // This will be used by IdentityIDForm for display
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

    try {
      final UserProfile? userProfile = await _profileService.fetchUserProfile(currentUser.id);
      if (userProfile != null) {
        // Populate controllers and state variables from fetched profile
        _fullNameController.text = userProfile.fullName ?? '';
        _displayNameController.text = userProfile.displayName ?? '';
        _heightController.text = userProfile.height?.toString() ?? '';
        _phoneNumberController.text = userProfile.phoneNumber ?? '';
        _addressZipController.text = userProfile.addressZip ?? '';
        _bioController.text = userProfile.bio ?? '';

        _dateOfBirth = userProfile.dateOfBirth;
        _gender = userProfile.gender;
        _sexualOrientation = userProfile.sexualOrientation;
        _lookingFor = userProfile.lookingFor;
        _selectedInterests = List.from(userProfile.interests); // Make a mutable copy
        _agreedToTerms = userProfile.agreedToTerms;
        _agreedToCommunityGuidelines = userProfile.agreedToCommunityGuidelines;
        _imagePreviewPath = userProfile.profilePictureUrl; // Set for existing image

        // --- Dating Preferences State population ---
        _preferredGender = userProfile.gender; // Assuming preferred gender defaults to user's gender
        // Age range might need more sophisticated logic if it's based on user's profile
        _ageRange = const RangeValues(18, 50); // Or fetch from userProfile if stored
        _maxDistance = 100; // Or fetch from userProfile if stored

        // --- Profile Visibility State population ---
        // These logic lines should be based on actual fields in UserProfile for visibility settings
        _showFullName = userProfile.fullName != null; 
        _showDisplayName = userProfile.displayName != null;
        _showAge = userProfile.dateOfBirth != null;
        _showGender = userProfile.gender != null;
        _showBio = userProfile.bio != null;
        _showSexualOrientation = userProfile.sexualOrientation != null;
        _showHeight = userProfile.height != null;
        _showInterests = userProfile.interests.isNotEmpty;
        _showLookingFor = userProfile.lookingFor != null;
        _showLocation = userProfile.addressZip != null;
        // The remaining _show flags need corresponding fields in UserProfile to be correctly populated
        _showEthnicity = false; // Example: userProfile.ethnicity != null;
        _showLanguagesSpoken = false; // userProfile.languagesSpoken.isNotEmpty;
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
    // Validate current tab's form before saving all
    if (!_formKeys[_tabController.index].currentState!.validate()) {
      debugPrint('ProfileSetupScreen: Validation failed for current tab.');
      // Show a message to the user that validation failed
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

    String? uploadedPhotoPath;
    if (_pickedImage != null) {
      try {
        uploadedPhotoPath = await _profileService.uploadAnalysisPhoto(currentUser.id, _pickedImage!);
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
      // If no new image picked, but there's an existing preview path (from loaded profile)
      uploadedPhotoPath = _imagePreviewPath;
    } else {
      debugPrint('ProfileSetupScreen: No analysis photo provided, continuing without upload.');
    }

    try {
      // Ensure all required fields are non-null before creating UserProfile
      // The validators in the forms should prevent this from being an issue if fields are required.
      // If any of these can genuinely be null in your UserProfile model and database,
      // you should remove the '!' operator and ensure UserProfile fields are nullable.
      final UserProfile profile = UserProfile(
        userId: currentUser.id,
        email: currentUser.email!, // Provide email from currentUser
        fullName: _fullNameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        phoneNumber: _phoneNumberController.text.trim(),
        addressZip: _addressZipController.text.trim(),
        profilePictureUrl: uploadedPhotoPath,
        sexualOrientation: _sexualOrientation!,
        lookingFor: _lookingFor!,
        height: double.tryParse(_heightController.text.trim()),
        bio: _bioController.text.trim(),
        interests: _selectedInterests,
        isProfileComplete: true,
        agreedToTerms: _agreedToTerms,
        agreedToCommunityGuidelines: _agreedToCommunityGuidelines,
        createdAt: currentUser.createdAt != null
            ? DateTime.tryParse(currentUser.createdAt!) ?? DateTime.now()
            : DateTime.now(),
      );

      await _profileService.createOrUpdateProfile(profile: profile);

      debugPrint('User profile ${currentUser.id} updated successfully in Supabase.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        context.go('/home'); // Redirect to home/dashboard
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
    final colorScheme = Theme.of(context).colorScheme;

    final Color primaryColor = isDarkMode ? Colors.deepPurpleAccent : Colors.blue.shade700;
    final Color secondaryColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color accentColor = isDarkMode ? Colors.cyanAccent : Colors.orangeAccent;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      // The background gradient/effect for the entire Profile Setup Screen
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()), // Reuse the immersive background
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