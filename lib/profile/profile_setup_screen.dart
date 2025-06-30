// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW: Supabase import
import 'package:bliindaidating/services/auth_service.dart'; // Keep, for current user logic
import 'package:bliindaidating/models/user_profile.dart'; // Keep, for profile data structure
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // Your main app screen
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _gender;
  String? _lookingFor;
  final List<String> _selectedInterests = [];
  bool _isLoading = false;
  String? _statusMessage;

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
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
        _statusMessage = null;
      });

      // Get the current user's ID from Supabase Auth
      final User? supabaseUser = Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in to Supabase! Please log in again.')),
        );
        setState(() { _isLoading = false; });
        if (mounted) {
          GoRouter.of(context).go('/login'); // Redirect to login if no Supabase user
        }
        return;
      }

      // Create a UserProfile object with the collected data
      final UserProfile updatedProfile = UserProfile(
        uid: supabaseUser.id, // Use Supabase user ID
        email: supabaseUser.email ?? 'no-email@supabase.com', // Use Supabase user email
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        gender: _gender,
        interests: _selectedInterests,
        lookingFor: _lookingFor ?? '',
        createdAt: DateTime.now(),
        profileComplete: true,
        lastUpdated: DateTime.now(),
      );

      try {
        // --- Supabase Database: Save Profile ---
        // You need to have a table named 'profiles' (or 'users') in your Supabase project
        // with columns matching your UserProfile model.
        // Example: id (UUID), email (text), display_name (text), bio (text), gender (text),
        // interests (jsonb or text[]), looking_for (text), created_at (timestampz),
        // profile_complete (boolean), last_updated (timestampz).
        // Ensure Row Level Security (RLS) is configured in Supabase for this table.
        await Supabase.instance.client
            .from('profiles') // Assuming your table is named 'profiles'
            .upsert(updatedProfile.toMap()); // Use upsert to insert or update based on primary key (uid)

        debugPrint('User profile ${updatedProfile.uid} updated successfully in Supabase.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        if (mounted) {
          GoRouter.of(context).go('/home'); // Navigate to the main dashboard
        }
      } on PostgrestException catch (e) {
        debugPrint('Supabase database error saving profile: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.message}')),
        );
      } catch (e) {
        debugPrint('Unexpected error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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

              // Gender Selection
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

              // Looking For Option
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

              // Interests Selection (Chip-based)
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
