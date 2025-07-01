// lib/profile/about_me_screen.dart
import 'package:flutter/material.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;


class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final _form_key = GlobalKey<FormState>();
  final TextEditingController _display_name_controller = TextEditingController();
  final TextEditingController _bio_controller = TextEditingController();
  final ProfileService _profile_service = ProfileService();
  final ImagePicker _picker = ImagePicker();

  UserProfile? _user_profile;
  String? _gender;
  String? _looking_for;
  final List<String> _selected_interests = [];
  XFile? _picked_image;
  String? _displayed_avatar_url;
  bool _is_loading = true;

  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say'
  ];
  final List<String> _looking_for_options = [
    'Short-term dating', 'Long-term relationship', 'Friendship'
  ];
  final List<String> _all_interests = [
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
    _display_name_controller.dispose();
    _bio_controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _is_loading = true;
    });

    final User? current_user = Supabase.instance.client.auth.currentUser;
    if (current_user == null) {
      debugPrint('No current user authenticated to load profile.');
      setState(() { _is_loading = false; });
      return;
    }

    try {
      final UserProfile? profile = await _profile_service.getProfile(current_user.id);

      if (profile != null) {
        _user_profile = profile;
        _display_name_controller.text = profile.display_name;
        _bio_controller.text = profile.bio;
        _gender = profile.gender;
        _looking_for = profile.looking_for;
        _selected_interests.clear();
        _selected_interests.addAll(profile.interests);

        if (profile.avatar_url != null) {
          final String? signed_url = await _profile_service.getAnalysisPhotoSignedUrl(profile.avatar_url!);
          setState(() {
            _displayed_avatar_url = signed_url;
          });
        }
      } else {
        debugPrint('Profile not found for user: ${current_user.id}');
        // Create a default profile object if none found, to avoid null access issues
        _user_profile = UserProfile.fromSupabaseUser(current_user);
        _display_name_controller.text = current_user.email?.split('@').first ?? '';
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
        _is_loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _picked_image = image;
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
    if (!_form_key.currentState!.validate()) {
      return;
    }
    _form_key.currentState!.save();

    setState(() {
      _is_loading = true;
    });

    final User? current_user = Supabase.instance.client.auth.currentUser;
    if (current_user == null || _user_profile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in or profile not loaded.')),
        );
        setState(() { _is_loading = false; });
        return;
      }
    }

    String? new_avatar_path = _user_profile?.avatar_url;

    if (_picked_image != null) {
      try {
        new_avatar_path = await _profile_service.uploadAnalysisPhoto(current_user!.id, _picked_image!);
        if (new_avatar_path == null) {
          throw Exception('Failed to upload new photo.');
        }
      } catch (e) {
        debugPrint('Error uploading new photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update photo: ${e.toString()}')),
          );
          setState(() { _is_loading = false; });
          return;
        }
      }
    }

    final UserProfile updated_profile = _user_profile!.copyWith(
      display_name: _display_name_controller.text.trim(),
      bio: _bio_controller.text.trim(),
      gender: _gender,
      interests: _selected_interests,
      looking_for: _looking_for,
      profile_complete: true,
      avatar_url: new_avatar_path,
    );

    try {
      await _profile_service.createOrUpdateProfile(updated_profile);
      debugPrint('Profile for ${updated_profile.uid} updated successfully.');
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
        _is_loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_is_loading && _user_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user_profile == null && !_is_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No profile data available.', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadUserProfile(),
              child: const Text('Try Reloading Profile'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _form_key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Your Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple.shade800,
                  backgroundImage: _picked_image != null
                      ? (kIsWeb ? NetworkImage(_picked_image!.path) : FileImage(File(_picked_image!.path))) as ImageProvider
                      : (_displayed_avatar_url != null ? NetworkImage(_displayed_avatar_url!) : null),
                  child: _picked_image == null && _displayed_avatar_url == null
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
                onPressed: _is_loading ? null : _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _is_loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Changes',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}