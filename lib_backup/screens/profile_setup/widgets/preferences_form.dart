// lib/screens/profile_setup/widgets/preferences_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

// Helper widget for a category of interests (remains similar)
class _InterestCategorySection extends StatelessWidget {
  final String title;
  final List<String> interests;
  final List<String> selectedInterests;
  final Function(String) onInterestSelected;
  final Function(String) onInterestDeselected;
  final bool isDarkMode;
  final TextTheme textTheme;
  final Color activeColor;
  final Color widgetBackgroundColor;
  final Color primaryTextColor; // Added for internal use

  const _InterestCategorySection({
    required this.title,
    required this.interests,
    required this.selectedInterests,
    required this.onInterestSelected,
    required this.onInterestDeselected,
    required this.isDarkMode,
    required this.textTheme,
    required this.activeColor,
    required this.widgetBackgroundColor,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: (interests ?? []).map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest, style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : primaryTextColor)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onInterestSelected(interest);
                } else {
                  onInterestDeselected(interest);
                }
              },
              selectedColor: activeColor.withOpacity(0.7),
              checkmarkColor: isDarkMode ? Colors.black : Colors.white,
              backgroundColor: widgetBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? activeColor : secondaryTextColor.withOpacity(0.5)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class PreferencesForm extends StatefulWidget {
  final TextEditingController bioController;
  final Function(String?) onSexualOrientationChanged;
  final Function(String?) onLookingForChanged;
  final Function(String) onInterestSelected;
  final Function(String) onInterestDeselected;
  final String? sexualOrientation;
  final String? lookingFor;
  final List<String> selectedInterests;
  final GlobalKey<FormState> formKey;

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
  bool _showMoreInterests = false; // State for "More Options"

  final List<String> _sexualOrientations = [
    'Straight', 'Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Asexual',
    'Demisexual', 'Queer', 'Other', 'Prefer not to say'
  ];
  final List<String> _lookingForOptions = [
    'Long-term relationship', 'Short-term dating', 'Casual dating',
    'Friendship', 'Networking', 'Marriage', 'Something casual',
    'Still figuring it out'
  ];

  // Categorized Interests
  final Map<String, List<String>> _interestCategories = {
    'Arts & Culture': ['Reading', 'Writing', 'Painting', 'Sculpting', 'Photography', 'Theater', 'Museums', 'Galleries', 'Concerts', 'Opera'],
    'Outdoors & Adventure': ['Hiking', 'Camping', 'Cycling', 'Running', 'Swimming', 'Skiing', 'Snowboarding', 'Climbing', 'Kayaking', 'Fishing', 'Gardening'],
    'Technology & Gaming': ['Video Games', 'Board Games', 'Coding', 'Robotics', 'AI', 'Virtual Reality', 'Esports', 'Cybersecurity'],
    'Food & Drink': ['Cooking', 'Baking', 'Grilling', 'Wine Tasting', 'Craft Beer', 'Coffee', 'Exploring Cafes', 'Dining Out'],
    'Sports & Fitness': ['Gym', 'Yoga', 'Pilates', 'Basketball', 'Soccer', 'Tennis', 'Golf', 'Martial Arts', 'Dance', 'Team Sports'],
    'Music & Performing Arts': ['Playing Instruments', 'Singing', 'Dancing', 'Concert-going', 'Music Production', 'DJing'],
    'Travel & Exploration': ['Backpacking', 'Road Trips', 'International Travel', 'Cultural Exchange', 'Exploring New Cities', 'Photography while traveling'],
    'Learning & Education': ['Documentaries', 'Podcasts', 'Languages', 'Science', 'History', 'Philosophy', 'Debate'],
    'Community & Volunteering': ['Volunteering', 'Activism', 'Charity Work', 'Community Events', 'Mentoring'],
    'Relaxation & Wellness': ['Meditation', 'Mindfulness', 'Spa Days', 'Nature Walks', 'Journaling', 'Yoga', 'Reading (relaxing)'],
    'Animals & Pets': ['Pet Ownership', 'Animal Welfare', 'Dog Walking', 'Bird Watching'],
    'Fashion & Style': ['Shopping', 'Thrifting', 'Designing Clothes', 'Personal Styling', 'Makeup Artistry'],
    'Cars & Motors': ['Car Enthusiast', 'Motorcycles', 'Racing', 'Car Shows'],
    'Home & DIY': ['Home Improvement', 'Interior Design', 'Woodworking', 'Crafting', 'Knitting/Crochet'],
    'Movies & TV': ['Movie Marathons', 'Binge-watching Series', 'Film Analysis', 'Attending Film Festivals'],
  };

  // Define primary interests to show initially (select a few popular ones)
  final List<String> _primaryInterests = [
    'Reading', 'Hiking', 'Cooking', 'Video Games', 'Music', 'Travel', 'Photography', 'Sports', 'Art', 'Writing', 'Dancing',
  ];


  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? Colors.pinkAccent : Colors.red.shade600;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container( // Wrap with Container for custom background/shadows
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.9),
              cardColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0), // Inner padding
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to space between
                children: [
                  Expanded(
                    child: Text(
                      'Your Preferences',
                      style: textTheme.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                  ),
                  // "Blind AI Dating" title
                  Text(
                    'Blind AI Dating',
                    style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  ),
                  const SizedBox(width: 8), // Small space between text and icon
                  SvgPicture.asset(
                    'assets/svg/DrawKit Vector Illustration Love & Dating (5).svg', // Example SVG for Preferences
                    height: 50,
                    semanticsLabel: 'Preferences Icon',
                    colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your preferences for dating and relationships. This helps us find the best matches for you. Your selections here will influence who you see and who sees you.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: widget.sexualOrientation,
                decoration: InputDecoration(
                  labelText: 'Sexual Orientation',
                  labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.diversity_3, color: secondaryTextColor),
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                dropdownColor: cardColor, // Ensure dropdown is themed
                style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
                items: (_sexualOrientations ?? []).map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onSexualOrientationChanged(newValue);
                },
                validator: (value) {
                  if (value == null || (value ?? []).isEmpty) {
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
                  labelStyle: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.favorite, color: secondaryTextColor),
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                dropdownColor: cardColor, // Ensure dropdown is themed
                style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor),
                items: (_lookingForOptions ?? []).map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: primaryTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onLookingForChanged(newValue);
                },
                validator: (value) {
                  if (value == null || (value ?? []).isEmpty) {
                    return 'Please select what you\'re looking for.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: widget.bioController,
                maxLength: 2000,
                maxLines: 4,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'About Me (Bio)',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: secondaryTextColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.description, color: secondaryTextColor),
                  hintText: 'Tell us a bit about yourself (max 2000 characters)...',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write a short bio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'The more honest and extensive your bio, the easier it is for our AI to learn about you and find truly compatible matches. Your bio will only be public on your profile card if you choose to make it so in Settings.',
                style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.8)),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Text(
                'Select Your Interests:',
                style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: 8),
              // Primary Interests
              _InterestCategorySection(
                title: 'Popular Interests',
                interests: _primaryInterests,
                selectedInterests: widget.selectedInterests,
                onInterestSelected: widget.onInterestSelected,
                onInterestDeselected: widget.onInterestDeselected,
                isDarkMode: isDarkMode,
                textTheme: textTheme,
                activeColor: activeColor,
                widgetBackgroundColor: cardColor,
                primaryTextColor: primaryTextColor,
              ),
              // "More Options" button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showMoreInterests = !_showMoreInterests;
                    });
                  },
                  icon: Icon(_showMoreInterests ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  label: Text(_showMoreInterests ? 'Hide More Interests' : 'Show More Interests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor.withOpacity(0.1),
                    foregroundColor: activeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Collapsible section for more interests
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _showMoreInterests ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _interestCategories.entries.where((entry) => !_primaryInterests.any((p) => entry.value.contains(p))).map((entry) {
                    return _InterestCategorySection(
                      title: entry.key,
                      interests: entry.value,
                      selectedInterests: widget.selectedInterests,
                      onInterestSelected: widget.onInterestSelected,
                      onInterestDeselected: widget.onInterestDeselected,
                      isDarkMode: isDarkMode,
                      textTheme: textTheme,
                      activeColor: activeColor,
                      widgetBackgroundColor: cardColor,
                      primaryTextColor: primaryTextColor,
                    );
                  }).toList(),
                ),
              ),
              // Validator for interests
              FormField<List<String>>(
                initialValue: widget.selectedInterests,
                validator: (value) {
                  if (value == null || (value ?? []).isEmpty) {
                    return 'Please select at least one interest.';
                  }
                  return null;
                },
                builder: (FormFieldState<List<String>> state) {
                  if (state.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        state.errorText!,
                        style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
