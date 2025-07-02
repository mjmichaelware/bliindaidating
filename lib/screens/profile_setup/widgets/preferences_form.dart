// lib/screens/profile_setup/widgets/preferences_form.dart

import 'package:flutter/material.dart';

class PreferencesForm extends StatefulWidget {
  final TextEditingController bioController;
  final Function(String?) onSexualOrientationChanged;
  final Function(String?) onLookingForChanged;
  final Function(String) onInterestSelected;
  final Function(String) onInterestDeselected;
  final String? sexualOrientation;
  final String? lookingFor;
  final List<String> selectedInterests;
  final GlobalKey<FormState> formKey; // Receive the form key from parent

  const PreferencesForm({
    super.key,
    required this.bioController,
    required this.onSexualOrientationChanged,
    required this.onLookingForChanged,
    required this.onInterestSelected,
    required this.onInterestDeselected,
    this.sexualOrientation,
    this.lookingFor,
    required this.selectedInterests,
    required this.formKey,
  });

  @override
  State<PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  final List<String> _sexualOrientations = [
    'Straight', 'Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Asexual',
    'Demisexual', 'Queer', 'Other', 'Prefer not to say'
  ];
  final List<String> _lookingForOptions = [
    'Long-term relationship', 'Short-term dating', 'Casual dating',
    'Friendship', 'Networking', 'Marriage', 'Something casual',
    'Still figuring it out'
  ];
  final List<String> _allInterests = [ // Keeping original for now
    'Reading', 'Hiking', 'Cooking', 'Gaming', 'Music', 'Movies', 'Travel',
    'Photography', 'Sports', 'Art', 'Writing', 'Dancing', 'Volunteering',
    'Fitness', 'Tech', 'Tasting', 'Animals', 'Fashion'
  ];

  @override
  Widget build(BuildContext context) {
    return Form( // Each tab now has its own Form, but uses the parent's key
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: widget.sexualOrientation,
            decoration: InputDecoration(
              labelText: 'Sexual Orientation',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.diversity_3),
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            items: _sexualOrientations.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: const TextStyle(fontFamily: 'Inter')),
              );
            }).toList(),
            onChanged: (String? newValue) {
              widget.onSexualOrientationChanged(newValue);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your sexual orientation.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.lookingFor,
            decoration: InputDecoration(
              labelText: 'Looking For',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.favorite),
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            items: _lookingForOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: const TextStyle(fontFamily: 'Inter')),
              );
            }).toList(),
            onChanged: (String? newValue) {
              widget.onLookingForChanged(newValue);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select what you\'re looking for.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: widget.bioController,
            decoration: InputDecoration(
              labelText: 'About Me (Bio)',
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.description),
              hintText: 'Tell us a bit about yourself...',
              hintStyle: TextStyle(fontFamily: 'Inter', color: Theme.of(context).hintColor),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please write a short bio.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Select Your Interests:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _allInterests.map((interest) {
              final isSelected = widget.selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest, style: const TextStyle(fontFamily: 'Inter')),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    widget.onInterestSelected(interest);
                  } else {
                    widget.onInterestDeselected(interest);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}