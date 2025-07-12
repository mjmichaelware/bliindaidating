// lib/screens/profile_setup/widgets/preferences_form.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG assets

// Helper widget for a category of interests
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
  final Color primaryTextColor;
  final Color secondaryTextColor;

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
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingExtraSmall,
          children: interests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(
                interest,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Inter',
                  color: isSelected ? (isDarkMode ? Colors.black : Colors.white) : primaryTextColor,
                ),
              ),
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
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                side: BorderSide(color: isSelected ? activeColor : secondaryTextColor.withOpacity(0.5)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
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
  final String? maritalStatus; // New parameter
  final Function(String?) onMaritalStatusChanged; // New parameter
  final String? ethnicity; // New parameter
  final Function(String?) onEthnicityChanged; // New parameter


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
    this.maritalStatus, // Initialize here
    required this.onMaritalStatusChanged, // Initialize here
    this.ethnicity, // Initialize here
    required this.onEthnicityChanged, // Initialize here
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
  final List<String> _maritalStatusOptions = [ // New options
    'Single', 'Married', 'Divorced', 'Widowed', 'Separated', 'In a relationship', 'It\'s complicated', 'Prefer not to say'
  ];
  final List<String> _ethnicityOptions = [ // New options
    'Asian', 'Black', 'Hispanic', 'White', 'Indigenous', 'Mixed', 'Other', 'Prefer not to say'
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

    // Define theme-dependent colors for consistent UI
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54;
    final Color activeColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;
    final Color inputFillColor = isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
    final Color inputBorderColor = secondaryTextColor.withOpacity(0.3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium), // Consistent padding
      child: Container( // Wrap with Container for custom background/shadows
        // Apply the beautiful background, border, shadow, and gradient
        decoration: BoxDecoration(
          color: cardColor, // Base background color for the form panel
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.2), // Subtle glow effect
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient( // Elegant gradient for depth
            colors: [
              cardColor.withOpacity(0.9), // Slightly transparent to show background
              cardColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all( // Subtle border for definition
            color: (isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingLarge), // Inner padding for content
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Title and App Name/Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Preferences & More', // Updated title
                      style: textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        fontSize: AppConstants.fontSizeExtraLarge,
                      ),
                    ),
                  ),
                  // App Name and Icon for branding
                  Row(
                    children: [
                      Text(
                        'Blind AI Dating',
                        style: textTheme.bodySmall?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      SvgPicture.asset(
                        'assets/svg/DrawKit Vector Illustration Love & Dating (5).svg', // Example SVG for Preferences
                        height: 40,
                        semanticsLabel: 'Preferences Icon',
                        colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Help us understand your preferences and personality. This helps us find the best matches for you.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: AppConstants.spacingLarge), // Increased spacing

              // About Me (Bio) Input Field
              TextFormField(
                controller: widget.bioController,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'About Me (Bio)',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  alignLabelWithHint: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.description, color: secondaryTextColor),
                  hintText: 'Share something interesting about yourself...',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: secondaryTextColor.withOpacity(0.7)),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write a short bio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Sexual Orientation Dropdown
              DropdownButtonFormField<String>(
                value: widget.sexualOrientation,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                dropdownColor: cardColor, // Dropdown menu background
                decoration: InputDecoration(
                  labelText: 'Sexual Orientation',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.favorite, color: secondaryTextColor),
                ),
                items: _sexualOrientations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor, fontFamily: 'Inter')),
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
              const SizedBox(height: AppConstants.spacingMedium),

              // Looking For Dropdown
              DropdownButtonFormField<String>(
                value: widget.lookingFor,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                dropdownColor: cardColor, // Dropdown menu background
                decoration: InputDecoration(
                  labelText: 'Looking For',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                ),
                items: _lookingForOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor, fontFamily: 'Inter')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onLookingForChanged(newValue);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select what you are looking for.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Marital Status Dropdown (NEW)
              DropdownButtonFormField<String>(
                value: widget.maritalStatus,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                dropdownColor: cardColor, // Dropdown menu background
                decoration: InputDecoration(
                  labelText: 'Marital Status',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.people_alt, color: secondaryTextColor),
                ),
                items: _maritalStatusOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor, fontFamily: 'Inter')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onMaritalStatusChanged(newValue);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your marital status.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Ethnicity Dropdown (NEW)
              DropdownButtonFormField<String>(
                value: widget.ethnicity,
                style: TextStyle(color: primaryTextColor, fontFamily: 'Inter'),
                dropdownColor: cardColor, // Dropdown menu background
                decoration: InputDecoration(
                  labelText: 'Ethnicity',
                  labelStyle: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.diversity_3, color: secondaryTextColor),
                ),
                items: _ethnicityOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: primaryTextColor, fontFamily: 'Inter')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  widget.onEthnicityChanged(newValue);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your ethnicity.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLarge),

              // Interests Section Header
              Text(
                'Your Interests',
                style: textTheme.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                'Select hobbies and interests that describe you. You can select multiple.',
                style: textTheme.bodyMedium?.copyWith(fontFamily: 'Inter', color: secondaryTextColor),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Popular Interests Section
              _InterestCategorySection(
                title: 'Popular Interests',
                interests: _primaryInterests,
                selectedInterests: widget.selectedInterests,
                onInterestSelected: widget.onInterestSelected,
                onInterestDeselected: widget.onInterestDeselected,
                isDarkMode: isDarkMode,
                textTheme: textTheme,
                activeColor: activeColor,
                widgetBackgroundColor: inputFillColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              
              // "Show More Interests" Button
              if (!_showMoreInterests)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMoreInterests = true;
                      });
                    },
                    icon: Icon(Icons.add_circle_outline, color: activeColor),
                    label: Text(
                      'Show More Interests',
                      style: textTheme.bodyLarge?.copyWith(fontFamily: 'Inter', color: activeColor, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
                    ),
                  ),
                ),

              // Dynamically show all categories if "More Options" is toggled
              if (_showMoreInterests)
                ..._interestCategories.entries.map((entry) {
                  return _InterestCategorySection(
                    title: entry.key,
                    interests: entry.value,
                    selectedInterests: widget.selectedInterests,
                    onInterestSelected: widget.onInterestSelected,
                    onInterestDeselected: widget.onInterestDeselected,
                    isDarkMode: isDarkMode,
                    textTheme: textTheme,
                    activeColor: activeColor,
                    widgetBackgroundColor: inputFillColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  );
                }).toList(),
              const SizedBox(height: AppConstants.paddingSmall), // Final spacing
            ],
          ),
        ),
      ),
    );
  }
}
