// lib/profile/ai_profile_generator_widget.dart

import 'package:flutter/material.dart';
import '../services/ai_logic_service.dart'; // Import your AI logic service
// You might also need services from your profile module here if you
// want to save the generated bio directly to the user's profile.
// import 'package:bliindaidating/services/profile_service.dart';

class AiProfileGeneratorWidget extends StatefulWidget {
  // Optional: Pass initial user data if you want to pre-fill the form fields
  final Map<String, String>? initialUserData;

  const AiProfileGeneratorWidget({super.key, this.initialUserData});

  @override
  State<AiProfileGeneratorWidget> createState() => _AiProfileGeneratorWidgetState();
}

class _AiProfileGeneratorWidgetState extends State<AiProfileGeneratorWidget> {
  final AiLogicService _aiService = AiLogicService(); // Instantiate your AI logic service
  // final ProfileService _profileService = ProfileService(); // Example: if you need to save the bio

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String? _generatedProfileBio;
  bool _isLoading = false; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if initialUserData is provided
    if (widget.initialUserData != null) {
      _nameController.text = widget.initialUserData!['name'] ?? '';
      _ageController.text = widget.initialUserData!['age'] ?? '';
      _hobbiesController.text = widget.initialUserData!['hobbies'] ?? '';
    }
  }

  Future<void> _generateProfile() async {
    // Basic validation
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _hobbiesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Name, Age, and Hobbies to generate a profile.')),
      );
      return;
    }

    // Show loading state and clear previous results
    setState(() {
      _isLoading = true;
      _generatedProfileBio = null;
    });

    // Prepare user data from text controllers
    final userData = {
      'name': _nameController.text,
      'age': _ageController.text,
      'hobbies': _hobbiesController.text,
    };
    // Pass instructions only if provided
    final instructions = _instructionsController.text.isNotEmpty ? _instructionsController.text : null;

    // Call the AI service to get the profile bio
    final bio = await _aiService.generateProfileBio(userData, instructions: instructions);

    // Update UI with results and hide loading
    setState(() {
      _generatedProfileBio = bio;
      _isLoading = false;
    });

    // Show a SnackBar if generation failed
    if (bio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate profile. Please check your backend and internet connection.')),
      );
    }
  }

  // Optional: Function to save the generated bio
  // Future<void> _saveGeneratedBio() async {
  //   if (_generatedProfileBio != null && _generatedProfileBio!.isNotEmpty) {
  //     // Assuming you have a method in ProfileService to update the user's bio
  //     await _profileService.updateUserProfileBio(_generatedProfileBio!);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Profile bio saved successfully!')),
  //     );
  //     // Maybe navigate away or update parent state
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Padding( // Added Padding for better visual spacing
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generate Your Profile Bio with AI',
            style: Theme.of(context).textTheme.headlineSmall, // Consistent styling
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Your Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _hobbiesController,
            decoration: const InputDecoration(
              labelText: 'Your Hobbies (e.g., hiking, reading, cooking)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true, // For multiline hint alignment
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _instructionsController,
            decoration: const InputDecoration(
              labelText: 'Additional AI Instructions (e.g., "Make it funny", "Highlight my love for dogs")',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading spinner
              : ElevatedButton.icon(
                  onPressed: _generateProfile, // Call the generation function
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Profile Bio'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
          const SizedBox(height: 20),
          if (_generatedProfileBio != null) // Display generated bio if available
            Card(
              elevation: 4, // Increased elevation for better visual
              margin: const EdgeInsets.symmetric(vertical: 10), // Margin around the card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Profile Bio:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    SelectableText( // Use SelectableText to allow copying the generated text
                      _generatedProfileBio!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          // Example: Copy to clipboard
                          // You'll need to import 'package:flutter/services.dart'; for Clipboard
                          // Clipboard.setData(ClipboardData(text: _generatedProfileBio!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile bio copied to clipboard!')),
                          );
                          // If you have a save function:
                          // _saveGeneratedBio();
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Bio'),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _ageController.dispose();
    _hobbiesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}