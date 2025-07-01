// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Ensure UserProfile is updated with snake_case properties
import 'package:bliindaidating/services/profile_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File type, used with FileImage on mobile
import 'package:flutter/foundation.dart' show kIsWeb;


class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _form_key = GlobalKey<FormState>(); // Renamed to snake_case
  final TextEditingController _display_name_controller = TextEditingController(); // Renamed to snake_case
  final TextEditingController _bio_controller = TextEditingController(); // Renamed to snake_case
  final ProfileService _profile_service = ProfileService(); // Renamed to snake_case
  final ImagePicker _picker = ImagePicker();

  String? _gender;
  String? _looking_for; // Renamed to snake_case
  final List<String> _selected_interests = []; // Renamed to snake_case
  XFile? _picked_image; // Renamed to snake_case
  String? _image_preview_path; // Renamed to snake_case
  bool _is_loading = false; // Renamed to snake_case

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];
  final List<String> _looking_for_options = [ // Renamed to snake_case
    'Short-term dating',
    'Long-term relationship',
    'Friendship'
  ];
  final List<String> _all_interests = [ // Renamed to snake_case
    'Reading', 'Hiking', 'Cooking', 'Gaming', 'Music', 'Movies', 'Travel',
    'Photography', 'Sports', 'Art', 'Writing', 'Dancing', 'Volunteering',
    'Fitness', 'Tech', 'Tasting', 'Animals', 'Fashion'
  ];

  @override
  void dispose() {
    _display_name_controller.dispose();
    _bio_controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _picked_image = image;
          _image_preview_path = image.path;
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

  void _saveProfile() async {
    if (!_form_key.currentState!.validate()) {
      return;
    }
    _form_key.currentState!.save();

    setState(() {
      _is_loading = true;
    });

    final User? supabase_user = Supabase.instance.client.auth.currentUser;
    if (supabase_user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in! Please log in again.')),
        );
        setState(() { _is_loading = false; });
        context.go('/login');
      }
      return;
    }

    String? uploaded_photo_path;
    if (_picked_image != null) {
      try {
        uploaded_photo_path = await _profile_service.uploadAnalysisPhoto(supabase_user.id, _picked_image!);
        if (uploaded_photo_path == null) {
          throw Exception('Failed to get uploaded photo path.');
        }
      } catch (e) {
        debugPrint('Error uploading photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo: ${e.toString()}')),
          );
          setState(() { _is_loading = false; });
          return;
        }
      }
    }

    // FIXED: Robustly handle createdAt from User object for UserProfile constructor
    final DateTime final_created_at = (supabase_user.createdAt is DateTime)
        ? (supabase_user.createdAt as DateTime)
        : DateTime.now(); // Fallback if createdAt is null or not DateTime


    UserProfile new_profile = UserProfile(
      uid: supabase_user.id,
      email: supabase_user.email ?? '',
      display_name: _display_name_controller.text.trim(),
      bio: _bio_controller.text.trim(),
      gender: _gender,
      interests: _selected_interests,
      looking_for: _looking_for ?? '',
      profile_complete: true,
      created_at: final_created_at, // Use the robustly determined DateTime
      avatar_url: uploaded_photo_path,
    );

    try {
      await _profile_service.createOrUpdateProfile(new_profile);
      debugPrint('User profile ${new_profile.uid} updated successfully in Supabase.');
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
        _is_loading = false;
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
          key: _form_key,
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
                    backgroundImage: _image_preview_path != null
                        ? (kIsWeb ? NetworkImage(_image_preview_path!) : FileImage(File(_image_preview_path!))) as ImageProvider
                        : null,
                    child: _image_preview_path == null
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
                controller: _display_name_controller,
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
                controller: _bio_controller,
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
                onChanged: (String? new_value) {
                  setState(() {
                    _gender = new_value;
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
                value: _looking_for,
                decoration: const InputDecoration(
                  labelText: 'Looking For',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.favorite),
                ),
                items: _looking_for_options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? new_value) {
                  setState(() {
                    _looking_for = new_value;
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
                children: _all_interests.map((interest) {
                  final is_selected = _selected_interests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: is_selected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selected_interests.add(interest);
                        } else {
                          _selected_interests.remove(interest);
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
                  onPressed: _is_loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _is_loading
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