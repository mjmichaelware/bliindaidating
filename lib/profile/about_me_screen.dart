// lib/profile/about_me_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show File; // Keep for FileImage on non-web if needed, but we'll use Image.memory for XFile
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'dart:typed_data'; // For Uint8List to display image bytes
import 'package:provider/provider.dart'; // Import Provider to access ProfileService

import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';

// You can uncomment and create a spacing_constants.dart if you want
// import 'package:bliindaidating/constants/spacing_constants.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressZipController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  UserProfile? _userProfile;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _sexualOrientation;
  String? _lookingFor;
  String? _profilePictureUrl; // The URL for display from Supabase
  XFile? _newPickedImage; // The newly picked image file (local path/blob URL)
  Uint8List? _newPickedImageBytes; // Bytes of the newly picked image for display
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
    // Delay loadProfile to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
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

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) context.go('/login');
      return;
    }

    // Access ProfileService via Provider
    final profileService = Provider.of<ProfileService>(context, listen: false);

    try {
      final UserProfile? profile = await profileService.fetchUserProfile(currentUser.id);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile.fullLegalName ?? profile.fullName ?? '';
          _displayNameController.text = profile.displayName ?? '';
          _bioController.text = profile.bio ?? '';
          _phoneNumberController.text = profile.phoneNumber ?? '';
          _addressZipController.text = profile.locationZipCode ?? profile.addressZip ?? '';
          _heightController.text = profile.heightCm?.toString() ?? profile.height?.toString() ?? '';
          _dateOfBirth = profile.dateOfBirth;
          _gender = profile.genderIdentity ?? profile.gender;
          _sexualOrientation = profile.sexualOrientation;
          _lookingFor = profile.lookingFor;
          _selectedInterests.clear();
          // Use profile.hobbiesAndInterests directly as it's already a List<String>
          _selectedInterests.addAll(profile.hobbiesAndInterests);
          _profilePictureUrl = profile.profilePictureUrl;
          _newPickedImage = null; // Clear any previously picked image on load
          _newPickedImageBytes = null; // Clear any cached bytes
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
        final bytes = await image.readAsBytes(); // Read bytes for display
        setState(() {
          _newPickedImage = image;
          _newPickedImageBytes = bytes;
          // _profilePictureUrl will remain the old URL until saved and reloaded
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
    if (!_formKey.currentState!.validate()) { // Validate all fields
      // Manual validation for date picker is handled below as it's not a TextFormField
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the errors in the form.')),
        );
      }
      return;
    }
    // Also check dateOfBirth after form validation as it's not a TextFormField
    if (_dateOfBirth == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date of Birth is required.')),
          );
        }
        return;
    }

    setState(() { _isLoading = true; });
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) context.go('/login');
      setState(() { _isLoading = false; });
      return;
    }

    // Access ProfileService via Provider
    final profileService = Provider.of<ProfileService>(context, listen: false);


    String? finalProfilePictureUrl = _profilePictureUrl; // Start with the existing URL
    if (_newPickedImage != null) { // If a new image was picked, upload it
      try {
        // Use the profileService from Provider
        finalProfilePictureUrl = await profileService.uploadAnalysisPhoto(currentUser.id, _newPickedImage!);
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
    } else if (finalProfilePictureUrl != null && !finalProfilePictureUrl.startsWith('http')) {
      // This handles a scenario where _profilePictureUrl might be a local path initially (though unlikely here)
      // or if you have a logic to clear the image and need to explicitly set URL to null.
      // For this screen, it's mostly about new uploads or retaining existing URL.
      finalProfilePictureUrl = null; // Ensure it's null if no valid URL and no new image
    }

    try {
      // AboutMeScreen is for updating an existing profile, so we always call updateProfile
      // We must ensure _userProfile is not null, which _loadProfile should guarantee.
      if (_userProfile == null) {
        throw Exception('User profile not loaded, cannot save changes.');
      }

      // Create a new UserProfile object using copyWith,
      // updating only the fields that are modified by this screen.
      final UserProfile profileToUpdate = _userProfile!.copyWith(
        fullLegalName: _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : null,
        displayName: _displayNameController.text.trim().isNotEmpty ? _displayNameController.text.trim() : null,
        dateOfBirth: _dateOfBirth,
        genderIdentity: _gender,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        profilePictureUrl: finalProfilePictureUrl,
        hobbiesAndInterests: _selectedInterests, // This replaces the entire list
        lookingFor: _lookingFor,
        phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
        locationZipCode: _addressZipController.text.trim().isNotEmpty ? _addressZipController.text.trim() : null,
        sexualOrientation: _sexualOrientation,
        heightCm: double.tryParse(_heightController.text.trim()),
        // All other fields from the UserProfile model that are not directly
        // editable on this AboutMeScreen will be carried over from the
        // existing _userProfile via the copyWith method.
      );

      await profileService.updateProfile(profileToUpdate);

      debugPrint('Profile for ${currentUser.id} updated successfully.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // After successful save, update the UI's displayed image URL and clear picked image data.
        setState(() {
          _profilePictureUrl = finalProfilePictureUrl;
          _newPickedImage = null; // Clear picked image after successful upload
          _newPickedImageBytes = null;
        });
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

    ImageProvider<Object>? backgroundImage;
    if (_newPickedImageBytes != null) {
      // Display the newly picked image from its bytes
      backgroundImage = MemoryImage(_newPickedImageBytes!);
    } else if (_profilePictureUrl != null && _profilePictureUrl!.startsWith('http')) {
      // Display the existing network image
      backgroundImage = NetworkImage(_profilePictureUrl!);
    }
    // If both are null, backgroundImage remains null, and the child Icon will show

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
      body: _isLoading && _userProfile == null // Show full loading only if initial load
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form( // Wrap with Form for validation
                key: _formKey, // Assign the GlobalKey
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                          backgroundImage: backgroundImage, // Use the determined background image
                          child: backgroundImage == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: Text(
                        'Tap to change profile picture',
                        style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Legal Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.badge),
                        labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full legal name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                        labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Display name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'About Me (Bio) *',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                        labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      maxLines: 4,
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bio cannot be empty.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ListTile(
                      title: Text(
                        _dateOfBirth == null
                            ? 'Select Date of Birth *'
                            : 'Date of Birth: ${DateFormat('yyyy-MM-dd').format(_dateOfBirth!)}',
                        style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter'),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDateOfBirth(context),
                    ),
                    // Manual validation message for date of birth
                    if (_dateOfBirth == null && !_isLoading && _formKey.currentState?.validate() == false)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                        child: Text(
                          'Date of Birth is required.',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender Identity *',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gender Identity is required.';
                        }
                        return null;
                      },
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _sexualOrientation,
                      decoration: InputDecoration(
                        labelText: 'Sexual Orientation *',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sexual Orientation is required.';
                        }
                        return null;
                      },
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _lookingFor,
                      decoration: InputDecoration(
                        labelText: 'Looking For *',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Looking For is required.';
                        }
                        return null;
                      },
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (cm) *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.accessibility_new),
                        labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      keyboardType: TextInputType.number,
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Height is required.';
                        }
                        final height = double.tryParse(value.trim());
                        if (height == null || height <= 0) {
                          return 'Please enter a valid number for height.';
                        }
                        return null;
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
                      // Optional: Add phone number validation
                      // validator: (value) {
                      //   if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      //     return 'Please enter a valid 10-digit phone number.';
                      //   }
                      //   return null;
                      // },
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
                      // Optional: Add zip code validation
                      // validator: (value) {
                      //   if (value != null && value.isNotEmpty && !RegExp(r'^\d{5}(?:[-\s]\d{4})?$').hasMatch(value)) {
                      //     return 'Please enter a valid zip code.';
                      //   }
                      //   return null;
                      // },
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
            ),
    );
  }
}