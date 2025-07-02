// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// Import the new modular form widgets
import 'package:bliindaidating/screens/profile_setup/widgets/basic_info_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/identity_id_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/preferences_form.dart';
import 'package:bliindaidating/screens/profile_setup/widgets/consent_form.dart';

// Import your UserProfile model and ProfileService
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final ProfileService _profileService = ProfileService();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _sexualOrientation;
  String? _lookingFor;
  XFile? _pickedImage;
  String? _imagePreviewPath;
  bool _agreedToTerms = false;
  bool _agreedToCommunityGuidelines = false;

  final TextEditingController _bioController = TextEditingController();
  final List<String> _selectedInterests = [];

  bool _isLoading = false;

  static const List<Tab> _profileTabs = <Tab>[
    Tab(text: 'Basic Info', icon: Icon(Icons.person)),
    Tab(text: 'Identity & ID', icon: Icon(Icons.credit_card)),
    Tab(text: 'Preferences', icon: Icon(Icons.favorite)),
    Tab(text: 'Consent', icon: Icon(Icons.check_circle_outline)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _profileTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadUserProfile();
  }

  void _handleTabChange() {
    setState(() {});
  }

  Future<void> _loadUserProfile() async {
    final User? supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser == null) return;

    try {
      // Changed to expect UserProfile?
      final UserProfile? fetchedProfile = await _profileService.fetchUserProfile(supabaseUser.id);
      if (fetchedProfile != null) {
        _fullNameController.text = fetchedProfile.fullName ?? '';
        _displayNameController.text = fetchedProfile.displayName ?? '';
        _phoneNumberController.text = fetchedProfile.phoneNumber ?? '';
        _addressZipController.text = fetchedProfile.addressZip ?? '';
        _heightController.text = fetchedProfile.height?.toString() ?? '';

        _dateOfBirth = fetchedProfile.dateOfBirth;
        _gender = fetchedProfile.gender;
        _sexualOrientation = fetchedProfile.sexualOrientation;
        _lookingFor = fetchedProfile.lookingFor;
        _bioController.text = fetchedProfile.bio ?? '';
        _selectedInterests.clear();
        _selectedInterests.addAll(fetchedProfile.interests);

        if (fetchedProfile.profilePictureUrl != null) {
          setState(() {
            _imagePreviewPath = fetchedProfile.profilePictureUrl;
          });
        }
        _agreedToTerms = fetchedProfile.agreedToTerms;
        _agreedToCommunityGuidelines = fetchedProfile.agreedToCommunityGuidelines;
      }
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        debugPrint('No existing profile found for user ${supabaseUser.id}. Starting fresh.');
      } else {
        debugPrint('Supabase Postgrest Error loading user profile: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: ${e.message}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _addressZipController.dispose();
    _heightController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onDateOfBirthSelected(DateTime? date) {
    setState(() {
      _dateOfBirth = date;
    });
  }

  void _onGenderChanged(String? gender) {
    setState(() {
      _gender = gender;
    });
  }

  void _onImagePicked(XFile? image) {
    setState(() {
      _pickedImage = image;
      _imagePreviewPath = image?.path;
    });
  }

  void _onSexualOrientationChanged(String? orientation) {
    setState(() {
      _sexualOrientation = orientation;
    });
  }

  void _onLookingForChanged(String? lookingFor) {
    setState(() {
      _lookingFor = lookingFor;
    });
  }

  void _onInterestSelected(String interest) {
    setState(() {
      _selectedInterests.add(interest);
    });
  }

  void _onInterestDeselected(String interest) {
    setState(() {
      _selectedInterests.remove(interest);
    });
  }

  void _onTermsChanged(bool? newValue) {
    setState(() {
      _agreedToTerms = newValue ?? false;
    });
  }

  void _onCommunityGuidelinesChanged(bool? newValue) {
    setState(() {
      _agreedToCommunityGuidelines = newValue ?? false;
    });
  }

  bool _validateCurrentTab() {
    final FormState? currentForm = _formKeys[_tabController.index].currentState;
    if (currentForm == null || !currentForm.validate()) {
      return false;
    }

    switch (_tabController.index) {
      case 0: // Basic Info
        if (_dateOfBirth == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your date of birth.')),
          );
          return false;
        }
        break;
      case 1: // Identity & ID
        if (_pickedImage == null && (_imagePreviewPath == null || !_imagePreviewPath!.startsWith('http'))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload your analysis photo.')),
          );
          return false;
        }
        break;
      case 3: // Consent
        if (!_agreedToTerms || !_agreedToCommunityGuidelines) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must agree to all terms and guidelines to proceed.')),
          );
          return false;
        }
        break;
    }
    return true;
  }

  void _goToNextTab() {
    if (_validateCurrentTab()) {
      if (_tabController.index < _profileTabs.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      } else {
        _saveProfile();
      }
    }
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final User? supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in! Please log in again.')),
        );
        setState(() { _isLoading = false; });
        context.go('/login');
      }
      return;
    }

    String? uploadedPhotoPath;
    if (_pickedImage != null) {
      try {
        uploadedPhotoPath = await _profileService.uploadAnalysisPhoto(supabaseUser.id, _pickedImage!);
        if (uploadedPhotoPath == null) {
          throw Exception('Failed to get uploaded photo path after upload.');
        }
      } catch (e) {
        debugPrint('Error uploading photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo for analysis: ${e.toString()}')),
          );
          setState(() { _isLoading = false; });
          return;
        }
      }
    } else if (_imagePreviewPath != null && _imagePreviewPath!.startsWith('http')) {
      uploadedPhotoPath = _imagePreviewPath;
    } else {
      debugPrint('No analysis photo available to upload or save.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your analysis photo before completing profile.')),
        );
        setState(() { _isLoading = false; });
      }
      return;
    }

    try {
      final UserProfile profile = UserProfile(
        userId: supabaseUser.id,
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
        createdAt: supabaseUser.createdAt != null
            ? DateTime.tryParse(supabaseUser.createdAt!) ?? DateTime.now()
            : DateTime.now(), // Ensure createdAt is passed
      );

      await _profileService.createOrUpdateProfile(profile: profile);

      debugPrint('User profile ${supabaseUser.id} updated successfully in Supabase.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        context.go('/home');
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error saving profile data: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile data: $e');
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
    final double progress = (_tabController.index + 1) / _profileTabs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                color: Theme.of(context).colorScheme.secondary,
                minHeight: 10,
              ),
              TabBar(
                controller: _tabController,
                tabs: _profileTabs,
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                indicatorColor: Theme.of(context).colorScheme.secondary,
                labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
                isScrollable: true,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
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
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_tabController.index > 0)
                TextButton(
                  onPressed: _goToPreviousTab,
                  child: Text(
                    'Back',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontFamily: 'Inter'),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _goToNextTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            ],
          ),
        ),
      ),
    );
  }
}