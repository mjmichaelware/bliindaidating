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
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for theming (but not spacing)

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
  String? _gender;
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
          _fullNameController.text = profile.fullName ?? '';
          _displayNameController.text = profile.displayName ?? '';
          _bioController.text = profile.bio ?? '';
          _phoneNumberController.text = profile.phoneNumber ?? '';
          _addressZipController.text = profile.addressZip ?? '';
          _heightController.text = profile.height?.toString() ?? '';
          _dateOfBirth = profile.dateOfBirth;
          _gender = profile.gender;
          _sexualOrientation = profile.sexualOrientation;
          _lookingFor = profile.lookingFor;
          _selectedInterests.clear();
          _selectedInterests.addAll(profile.interests);
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
        fullName: _fullNameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        bio: _bioController.text.trim(),
        profilePictureUrl: finalProfilePictureUrl,
        isProfileComplete: true,
        interests: _selectedInterests,
        lookingFor: _lookingFor,
        phoneNumber: _phoneNumberController.text.trim(),
        addressZip: _addressZipController.text.trim(),
        sexualOrientation: _sexualOrientation,
        height: double.tryParse(_heightController.text.trim()),
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
              padding: const EdgeInsets.all(24.0), // Hardcoded value (was AppConstants.paddingLarge)
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
                  const SizedBox(height: 16.0), // Hardcoded value (was AppConstants.spacingMedium)
                  Center(
                    child: Text(
                      'Tap to change profile picture',
                      style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 24.0), // Hardcoded value (was AppConstants.spacingLarge)
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
                      labelText: 'Gender',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.transgender),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
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
                      labelText: 'Address / ZIP Code',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: 'Height (in cm or inches)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.height),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    keyboardType: TextInputType.text,
                    style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _sexualOrientation,
                    decoration: InputDecoration(
                      labelText: 'Sexual Orientation',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.diversity_3),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _sexualOrientations.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _sexualOrientation = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _lookingFor,
                    decoration: InputDecoration(
                      labelText: 'Looking For',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.favorite),
                      labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    items: _lookingForOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter')),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _lookingFor = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Your Interests:',
                    style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest, style: const TextStyle(fontFamily: 'Inter')),
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
                        selectedColor: colorScheme.primary.withOpacity(0.3),
                        checkmarkColor: colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Save Profile',
                              style: textTheme.labelLarge?.copyWith(fontFamily: 'Inter'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}