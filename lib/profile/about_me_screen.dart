// lib/profile/about_me_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
// Removed: import 'package:bliindaidating/app_constants.dart'; // No longer needed for spacing constants

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  UserProfile? _userProfile;
  DateTime? _dateOfBirth;
  String? _gender; // Old field, will map to genderIdentity
  String? _sexualOrientation;
  String? _lookingFor;
  String? _profilePictureUrl; // The URL for display
  XFile? _newPickedImage; // The newly picked image file
  bool _isLoading = false;

  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Transgender Male', 'Transgender Female',
    'Genderqueer', 'Genderfluid', 'Agender', 'Bigender', 'Two-Spirit',
    'Demigirl', 'Demiboy', 'Intersex', 'Other', 'Prefer not to say'
  ];
  final List<String> _sexualOrientations = [
    'Straight', 'Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Asexual',
    'Demisexual', 'Queer', 'Other', 'Prefer not to say'
  ];
  final List<String> _lookingForOptions = [
    'Long-term relationship', 'Short-term dating', 'Casual dating',
    'Friendship', 'Networking', 'Marriage', 'Something casual',
    'Still figuring it out'
  ];
  final List<String> _allInterests = [
    'Reading', 'Hiking', 'Cooking', 'Gaming', 'Music', 'Movies', 'Travel',
    'Photography', 'Sports', 'Art', 'Writing', 'Dancing', 'Volunteering',
    'Fitness', 'Tech', 'Tasting', 'Animals', 'Fashion'
  ];
  final List<String> _selectedInterests = [];


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneNumberController.dispose();
    _addressZipController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final UserProfile? profile = await _profileService.fetchUserProfile(currentUser.id);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile.fullLegalName ?? profile.fullName ?? ''; // Prioritize new field
          _displayNameController.text = profile.displayName ?? '';
          _bioController.text = profile.bio ?? '';
          _phoneNumberController.text = profile.phoneNumber ?? '';
          _addressZipController.text = profile.locationZipCode ?? profile.addressZip ?? ''; // Prioritize new field
          _heightController.text = profile.heightCm?.toString() ?? profile.height?.toString() ?? ''; // Prioritize new field
          _dateOfBirth = profile.dateOfBirth;
          _gender = profile.genderIdentity ?? profile.gender; // Prioritize new field
          _sexualOrientation = profile.sexualOrientation;
          _lookingFor = profile.lookingFor;
          _selectedInterests.clear();
          _selectedInterests.addAll(profile.hobbiesAndInterests.isNotEmpty ? profile.hobbiesAndInterests : profile.interests); // Prioritize new field
          _profilePictureUrl = profile.profilePictureUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _newPickedImage = image;
          _profilePictureUrl = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) context.go('/login');
      setState(() { _isLoading = false; });
      return;
    }

    String? finalProfilePictureUrl = _profilePictureUrl;
    if (_newPickedImage != null) {
      try {
        finalProfilePictureUrl = await _profileService.uploadAnalysisPhoto(currentUser.id, _newPickedImage!);
      } catch (e) {
        debugPrint('Error uploading new profile picture: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload new profile picture: ${e.toString()}')),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }
    }

    try {
      final UserProfile updatedProfile = (_userProfile ?? UserProfile.fromSupabaseUser(currentUser)).copyWith(
        // Fields being explicitly updated by AboutMeScreen
        fullLegalName: _fullNameController.text.trim(), // Map to new field
        displayName: _displayNameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        genderIdentity: _gender, // Map to new field
        bio: _bioController.text.trim(),
        profilePictureUrl: finalProfilePictureUrl,
        hobbiesAndInterests: _selectedInterests, // Map to new field
        lookingFor: _lookingFor,
        phoneNumber: _phoneNumberController.text.trim(),
        locationZipCode: _addressZipController.text.trim(), // Map to new field
        sexualOrientation: _sexualOrientation,
        heightCm: double.tryParse(_heightController.text.trim()), // Map to new field

        // Carry over existing phase completion status and consent flags
        isPhase1Complete: _userProfile?.isPhase1Complete ?? false,
        isPhase2Complete: _userProfile?.isPhase2Complete ?? false,
        agreedToTerms: _userProfile?.agreedToTerms ?? false,
        agreedToCommunityGuidelines: _userProfile?.agreedToCommunityGuidelines ?? false,

        // Carry over other existing fields that are not edited on this screen
        ethnicity: _userProfile?.ethnicity,
        languagesSpoken: _userProfile?.languagesSpoken,
        desiredOccupation: _userProfile?.desiredOccupation,
        educationLevel: _userProfile?.educationLevel,
        loveLanguages: _userProfile?.loveLanguages,
        favoriteMedia: _userProfile?.favoriteMedia,
        maritalStatus: _userProfile?.maritalStatus,
        hasChildren: _userProfile?.hasChildren,
        wantsChildren: _userProfile?.wantsChildren,
        relationshipGoals: _userProfile?.relationshipGoals,
        dealbreakers: _userProfile?.dealbreakers,
        religionOrSpiritualBeliefs: _userProfile?.religionOrSpiritualBeliefs,
        politicalViews: _userProfile?.politicalViews,
        diet: _userProfile?.diet,
        smokingHabits: _userProfile?.smokingHabits,
        drinkingHabits: _userProfile?.drinkingHabits,
        exerciseFrequencyOrFitnessLevel: _userProfile?.exerciseFrequencyOrFitnessLevel,
        sleepSchedule: _userProfile?.sleepSchedule,
        personalityTraits: _userProfile?.personalityTraits,
        willingToRelocate: _userProfile?.willingToRelocate,
        monogamyVsPolyamoryPreferences: _userProfile?.monogamyVsPolyamoryPreferences,
        astrologicalSign: _userProfile?.astrologicalSign,
        attachmentStyle: _userProfile?.attachmentStyle,
        communicationStyle: _userProfile?.communicationStyle,
        mentalHealthDisclosures: _userProfile?.mentalHealthDisclosures,
        petOwnership: _userProfile?.petOwnership,
        travelFrequencyOrFavoriteDestinations: _userProfile?.travelFrequencyOrFavoriteDestinations,
        profileVisibilityPreferences: _userProfile?.profileVisibilityPreferences,
        pushNotificationPreferences: _userProfile?.pushNotificationPreferences,
        createdAt: _userProfile?.createdAt,
        updatedAt: DateTime.now(),

        // Deprecated/Redundant fields (kept for compatibility during migration)
        fullName: _fullNameController.text.trim(), // Still mapping for compatibility
        gender: _gender, // Still mapping for compatibility
        addressZip: _addressZipController.text.trim(), // Still mapping for compatibility
        interests: _selectedInterests, // Still mapping for compatibility
        height: double.tryParse(_heightController.text.trim()), // Still mapping for compatibility
      );

      await _profileService.createOrUpdateProfile(profile: updatedProfile);

      debugPrint('Profile for ${updatedProfile.userId} updated successfully.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit About Me',
          style: textTheme.titleLarge?.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0), // Hardcoded value
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: colorScheme.primary.withOpacity(0.2),
                        backgroundImage: _profilePictureUrl != null
                            ? (kIsWeb
                                ? NetworkImage(_profilePictureUrl!) as ImageProvider<Object>
                                : FileImage(File(_profilePictureUrl!)) as ImageProvider<Object>)
                            : null,
                        child: _profilePictureUrl == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Hardcoded value
                  Center(
                    child: Text(
                      'Tap to change profile picture',
                      style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 24.0), // Hardcoded value
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Legal Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.badge),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person_outline),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'About Me (Bio)',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    maxLines: 4,
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: Text(
                      _dateOfBirth == null
                          ? 'Select Date of Birth'
                          : 'Date of Birth: ${DateFormat('yyyy-MM-dd').format(_dateOfBirth!)}',
                      style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter'),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDateOfBirth(context),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender Identity',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.transgender),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _genders.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _sexualOrientation,
                    decoration: InputDecoration(
                      labelText: 'Sexual Orientation',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.favorite),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _sexualOrientations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _sexualOrientation = newValue;
                      });
                    },
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _lookingFor,
                    decoration: InputDecoration(
                      labelText: 'Looking For',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _lookingForOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _lookingFor = newValue;
                      });
                    },
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.accessibility_new),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    keyboardType: TextInputType.number,
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    keyboardType: TextInputType.phone,
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _addressZipController,
                    decoration: InputDecoration(
                      labelText: 'Zip Code',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    keyboardType: TextInputType.number,
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Interests:',
                    style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest, style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter')),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: colorScheme.primary,
                        checkmarkColor: colorScheme.onPrimary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Save Profile', style: textTheme.labelLarge?.copyWith(fontFamily: 'Inter')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}