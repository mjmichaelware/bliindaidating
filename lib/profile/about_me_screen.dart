// lib/profile/about_me_screen.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
// REMOVED: import 'dart:io'; // Permanently removed; not needed with new image loading approach
import 'package:flutter/foundation.dart' show kIsWeb;

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  // Renamed all snake_case variables and controllers to camelCase
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ProfileService _profileService = ProfileService(); // Using singleton
  final ImagePicker _picker = ImagePicker();

  UserProfile? _userProfile; // Renamed
  String? _gender;
  String? _lookingFor; // Renamed
  final List<String> _selectedInterests = []; // Renamed
  XFile? _pickedImage; // Renamed
  String? _displayedAvatarUrl; // Renamed
  bool _isLoading = true; // Renamed

  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say'
  ];
  final List<String> _lookingForOptions = [
    'Short-term dating', 'Long-term relationship', 'Friendship'
  ];
  final List<String> _allInterests = [
    'Reading', 'Hiking', 'Cooking', 'Gaming', 'Music', 'Movies', 'Travel',
    'Photography', 'Sports', 'Art', 'Writing', 'Dancing', 'Volunteering',
    'Fitness', 'Tech', 'Tasting', 'Animals', 'Fashion'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('No current user authenticated to load profile.');
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Changed getProfile to getUserProfile as per ProfileService
      final UserProfile? profile = await _profileService.getUserProfile(currentUser.id);

      if (profile != null) {
        _userProfile = profile;
        // Updated to use camelCase properties from UserProfile
        _displayNameController.text = profile.fullName ?? ''; // Use fullName, provide default empty string
        _bioController.text = profile.bio ?? ''; // Use bio, handle nullability
        _gender = profile.gender;
        _lookingFor = profile.lookingFor; // Renamed
        _selectedInterests.clear();
        _selectedInterests.addAll(profile.interests); // Renamed

        // Updated to use profilePictureUrl (camelCase)
        if (profile.profilePictureUrl != null) {
          final String? signedUrl = await _profileService.getAnalysisPhotoSignedUrl(profile.profilePictureUrl!);
          setState(() {
            _displayedAvatarUrl = signedUrl; // Renamed
          });
        }
      } else {
        debugPrint('Profile not found for user: ${currentUser.id}. Creating default profile.');
        // Create a default profile object if none found, to avoid null access issues
        _userProfile = UserProfile.fromSupabaseUser(currentUser);
        _displayNameController.text = currentUser.email?.split('@').first ?? '';
        _displayedAvatarUrl = null; // No avatar URL if profile is newly created
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image; // Renamed
          _displayedAvatarUrl = null; // Clear network image if new local image is picked
        });
        debugPrint('Image picked for update: ${image.path}');
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

  void _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null || _userProfile == null) { // Renamed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in or profile not loaded.')),
        );
        setState(() { _isLoading = false; });
        return;
      }
    }

    String? newAvatarPath = _userProfile?.profilePictureUrl; // Updated to camelCase

    if (_pickedImage != null) { // Renamed
      try {
        // Pass XFile directly to service, it handles platform specific file reading
        newAvatarPath = await _profileService.uploadAnalysisPhoto(currentUser!.id, _pickedImage!);
        if (newAvatarPath == null) {
          throw Exception('Failed to upload new photo.');
        }
      } catch (e) {
        debugPrint('Error uploading new photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update photo: ${e.toString()}')),
          );
          setState(() { _isLoading = false; });
          return;
        }
      }
    }

    // Create updated profile using copyWith with camelCase parameters
    final UserProfile updatedProfile = _userProfile!.copyWith(
      fullName: _displayNameController.text.trim(), // Renamed
      bio: _bioController.text.trim(),
      gender: _gender,
      interests: _selectedInterests, // Renamed
      lookingFor: _lookingFor, // Renamed
      isProfileComplete: true, // Assuming profile is complete after editing
      profilePictureUrl: newAvatarPath, // Renamed
    );

    try {
      // Call createOrUpdateProfile with named arguments matching its signature
      await _profileService.createOrUpdateProfile(
        userId: currentUser!.id,
        fullName: updatedProfile.fullName!, // Assuming these are not null after validation
        dateOfBirth: updatedProfile.dateOfBirth!, // Assuming these are not null after validation
        gender: updatedProfile.gender!, // Assuming these are not null after validation
        bio: updatedProfile.bio!, // Assuming these are not null after validation
        profilePictureUrl: updatedProfile.profilePictureUrl,
        isProfileComplete: updatedProfile.isProfileComplete,
        interests: updatedProfile.interests,
        lookingFor: updatedProfile.lookingFor,
      );

      // Save interests and intentions separately if needed, otherwise removed if covered by createOrUpdateProfile
      // Given your original setup, these seem to be separate database updates.
      await _profileService.saveUserInterests(currentUser.id, _selectedInterests);
      await _profileService.saveUserIntentions(currentUser.id, [_lookingFor!]); // Assuming _lookingFor is not null

      // Corrected to use id (camelCase) from UserProfile
      debugPrint('Profile for ${updatedProfile.id} updated successfully.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile changes saved!')),
        );
        _loadUserProfile(); // Re-load profile to update UI with latest data and new signed URL
      }
    } catch (e) {
      debugPrint('Error saving profile changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: ${e.toString()}')),
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
    if (_isLoading && _userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No profile data available.', style: TextStyle(color: Colors.white, fontFamily: 'Inter')), // Ensure Inter font
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadUserProfile(),
              child: const Text('Try Reloading Profile', style: TextStyle(fontFamily: 'Inter')), // Ensure Inter font
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Your Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontFamily: 'Inter'), // Ensure Inter font
            ),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple.shade800,
                  backgroundImage: _pickedImage != null
                      ? (kIsWeb
                          // On web, XFile.path is a blob URL that NetworkImage can load.
                          ? NetworkImage(_pickedImage!.path) as ImageProvider<Object>
                          // On non-web, read bytes from XFile and use MemoryImage.
                          : MemoryImage(_pickedImage!.readAsBytesSync()) as ImageProvider<Object>
                         )
                      : (_displayedAvatarUrl != null // Use _displayedAvatarUrl for already uploaded image
                          ? NetworkImage(_displayedAvatarUrl!) as ImageProvider<Object>
                          : null),
                  child: _pickedImage == null && _displayedAvatarUrl == null // Check both picked and displayed for camera icon
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white.withOpacity(0.7),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'About Me (Bio)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please write a short bio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.transgender),
              ),
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _lookingFor,
              decoration: const InputDecoration(
                labelText: 'Looking For',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite),
              ),
              items: _lookingForOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _lookingFor = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select what you\'re looking for';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Text(
              'Select Your Interests:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Inter'), // Ensure Inter font
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _allInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest, style: const TextStyle(fontFamily: 'Inter')), // Ensure Inter font
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
                  selectedColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.3).round()),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Changes',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontFamily: 'Inter'), // Ensure Inter font
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}