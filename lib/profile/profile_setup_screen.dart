// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart'; // UserProfile updated with camelCase properties
import 'package:bliindaidating/services/profile_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// REMOVED: import 'dart:io'; // Permanently removed; not needed with new image loading approach
import 'package:flutter/foundation.dart' show kIsWeb; // For kIsWeb

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ProfileService _profileService = ProfileService(); // Singleton instance
  final ImagePicker _picker = ImagePicker();

  String? _gender;
  DateTime? _dateOfBirth;
  String? _lookingFor;
  final List<String> _selectedInterests = [];
  XFile? _pickedImage; // Stores the picked XFile
  // No longer need _imagePreviewPath if we directly use _pickedImage bytes for display
  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];
  final List<String> _lookingForOptions = [
    'Short-term dating',
    'Long-term relationship',
    'Friendship'
  ];
  final List<String> _allInterests = [
    'Reading', 'Hiking', 'Cooking', 'Gaming', 'Music', 'Movies', 'Travel',
    'Photography', 'Sports', 'Art', 'Writing', 'Dancing', 'Volunteering',
    'Fitness', 'Tech', 'Tasting', 'Animals', 'Fashion'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
          // _imagePreviewPath is no longer strictly needed if we load from _pickedImage bytes
          // but we will keep it consistent with AboutMeScreen for now, assuming it could be a URL
          // from a previous upload or a temporary path for display.
          // For direct display from picked XFile on mobile without dart:io,
          // we'll load bytes directly in the build method (carefully with FutureBuilder or if bytes are cached).
        });
        debugPrint('Image picked: ${image.path}');
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

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

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
          throw Exception('Failed to get uploaded photo path.');
        }
      } catch (e) {
        debugPrint('Error uploading photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo: ${e.toString()}')),
          );
          setState(() { _isLoading = false; });
          return;
        }
      }
    }

    if (_dateOfBirth == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your date of birth.')),
        );
        setState(() { _isLoading = false; });
      }
      return;
    }
    if (_gender == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender.')),
        );
        setState(() { _isLoading = false; });
      }
      return;
    }
    if (_lookingFor == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select what you are looking for.')),
        );
        setState(() { _isLoading = false; });
      }
      return;
    }

    try {
      await _profileService.createOrUpdateProfile(
        userId: supabaseUser.id,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        bio: _bioController.text.trim(),
        profilePictureUrl: uploadedPhotoPath,
        isProfileComplete: true,
        interests: _selectedInterests,
        lookingFor: _lookingFor!,
      );

      await _profileService.saveUserInterests(supabaseUser.id, _selectedInterests);
      await _profileService.saveUserIntentions(supabaseUser.id, [_lookingFor!]);


      debugPrint('User profile ${supabaseUser.id} updated successfully in Supabase.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        context.go('/home');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself!',
                style: Theme.of(context).textTheme.headlineMedium,
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
                        : null,
                    child: _pickedImage == null
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
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
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

              // Date of Birth Picker
              ListTile(
                title: Text(
                  _dateOfBirth == null
                      ? 'Select Date of Birth'
                      : 'Date of Birth: ${_dateOfBirth!.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateOfBirth(context),
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
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
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Profile',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}