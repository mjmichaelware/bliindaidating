// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bliindaidating/services/auth_service.dart'; // Import your AuthService
import 'package:bliindaidating/models/user_profile.dart'; // Import your UserProfile model
import 'package:bliindaidating/services/firestore_service.dart'; // Correct import for FirestoreService
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // Your main app screen
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: For Timestamp and FieldValue

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _gender;
  String? _lookingFor; // To capture short_term, long_term, friends
  final List<String> _selectedInterests = [];
  bool _isLoading = false; // ADDED: For loading state

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
    'Reading',
    'Hiking',
    'Cooking',
    'Gaming',
    'Music',
    'Movies',
    'Travel',
    'Photography',
    'Sports',
    'Art',
    'Writing',
    'Dancing',
    'Volunteering',
    'Fitness',
    'Tech',
    'Tasting',
    'Animals',
    'Fashion'
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form fields

      setState(() {
        _isLoading = true; // Set loading state
      });

      final User? currentUser = AuthService().getCurrentUser();
      if (currentUser == null) {
        // Handle case where user is not logged in (shouldn't happen here if flow is correct)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in! Please re-authenticate.')),
        );
        setState(() { _isLoading = false; }); // Reset loading state
        return;
      }

      // Create a UserProfile object with the collected data
      // Ensure UserProfile.toUpdateMap() correctly handles nulls or provides defaults
      final UserProfile updatedProfile = UserProfile(
        uid: currentUser.uid,
        email: currentUser.email!,
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        gender: _gender,
        interests: _selectedInterests,
        lookingFor: _lookingFor ?? '', // Default to empty if not selected
        // FIX: Timestamp.now() is now correctly imported from cloud_firestore
        createdAt: Timestamp.now(), // Use Timestamp from cloud_firestore
        profileComplete: true, // Mark profile as complete after setup
        lastUpdated: FieldValue.serverTimestamp(), // Add server timestamp for last update
      );

      try {
        // Use the FirestoreService to save the profile
        // FIX: Pass userId and profileData map as expected by FirestoreService
        await FirestoreService().updateUserProfile(
          userId: updatedProfile.uid,
          profileData: updatedProfile.toUpdateMap(), // Assuming toUpdateMap() provides a Map<String, dynamic>
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        // Navigate to the main dashboard after profile setup
        // FIX: Removed 'const' from MainDashboardScreen constructor call
        // Assuming MainDashboardScreen is a regular widget, not a const constructor.
        // Also using GoRouter for consistency with other navigations.
        if (mounted) {
          GoRouter.of(context).go('/home'); // Or '/main_dashboard' if that's the correct route
        }
      } catch (e) {
        debugPrint('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        // Using Theme.of(context).colorScheme.primary and onPrimary for consistency
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
                spacing: 8.0, // horizontal space between chips
                runSpacing: 4.0, // vertical space between lines
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
                    selectedColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
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
