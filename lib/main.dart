// lib/profile/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADDED: For Timestamp
import 'package:bliindaidating/services/firestore_service.dart'; // ADDED: For FirestoreService
import 'package:bliindaidating/screens/main/main_dashboard_screen.dart'; // ADDED: For MainDashboardScreen
import 'package:go_router/go_router.dart'; // For navigation

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage; // To show success/error messages

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty || bio.isEmpty) {
      setState(() {
        _statusMessage = 'Name and Bio cannot be empty.';
        _isLoading = false;
      });
      return;
    }

    try {
      // FIX: Use Timestamp.now() correctly
      // FIX: Call FirestoreService correctly
      await FirestoreService().updateUserProfile(
        userId: 'current_user_id_placeholder', // IMPORTANT: Replace with actual user ID (e.g., from FirebaseAuth.currentUser?.uid)
        profileData: {
          'name': name,
          'bio': bio,
          'createdAt': Timestamp.now(), // FIX: Timestamp is now defined
          'lastUpdated': FieldValue.serverTimestamp(), // Firestore field value for server-side timestamp
        },
      );

      setState(() {
        _statusMessage = 'Profile saved successfully!';
      });

      // FIX: Navigate to MainDashboardScreen. Removed 'const' if it's a StatefulWidget
      // Assuming MainDashboardScreen is not a const constructor, or if it is,
      // it should be used with `const` if all its parameters are const.
      // If MainDashboardScreen is a StatefulWidget, remove `const` here.
      // Given your tree, it's a regular screen, so `MainDashboardScreen()` is usually correct.
      if (mounted) {
        GoRouter.of(context).go('/home'); // Or to a more appropriate dashboard
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to save profile: ${e.toString()}';
      });
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
        title: const Text('Setup Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Placeholder for background if needed, or reuse AnimatedOrbBackground
          Container(color: Colors.black.withOpacity(0.7)), // Simple dark background
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tell Us About Yourself',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.purpleAccent,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'About Me (Bio)',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.purpleAccent,
                          ),
                          if (_statusMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                _statusMessage!,
                                style: TextStyle(color: _statusMessage!.contains('success') ? Colors.greenAccent : Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Save Profile',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
