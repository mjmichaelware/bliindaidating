import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService

class ProfileViewScreen extends StatefulWidget {
  final String? userId; // The ID of the profile to view
  const ProfileViewScreen({super.key, required this.userId});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (widget.userId == null) {
      setState(() {
        _errorMessage = 'User ID not provided.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you'd fetch the public profile data of the given userId
      // This will use your existing ProfileService, which should be able to fetch any user's profile.
      final profile = await _profileService.fetchUserProfile(widget.userId!);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Profile not found or is incomplete.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile for view: $e');
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userProfile?.displayName ?? _userProfile?.fullName ?? 'Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeExtraLarge,
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor))
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppConstants.errorColor, fontSize: AppConstants.fontSizeMedium),
                    textAlign: TextAlign.center,
                  ),
                )
              : _userProfile == null
                  ? Center(
                      child: Text(
                        'No profile data available.',
                        style: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: _userProfile!.profilePictureUrl != null
                                  ? NetworkImage(_userProfile!.profilePictureUrl!)
                                  : null,
                              child: _userProfile!.profilePictureUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 80,
                                      color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Center(
                            child: Text(
                              _userProfile!.displayName ?? _userProfile!.fullLegalName ?? 'Unnamed User',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: AppConstants.fontSizeExtraLarge,
                                color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                              ),
                            ),
                          ),
                          if (_userProfile!.bio != null && _userProfile!.bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
                              child: Center(
                                child: Text(
                                  _userProfile!.bio!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: AppConstants.fontSizeSmall,
                                    color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppConstants.spacingLarge),

                          // Profile Details Section
                          _buildProfileDetailCard(
                            context,
                            isDarkMode,
                            'Basic Information',
                            [
                              if (_userProfile!.genderIdentity != null)
                                _buildDetailRow(
                                  context,
                                  Icons.transgender,
                                  'Gender',
                                  _userProfile!.genderIdentity!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.dateOfBirth != null)
                                _buildDetailRow(
                                  context,
                                  Icons.cake,
                                  'Age',
                                  '${(DateTime.now().year - _userProfile!.dateOfBirth!.year)} years old',
                                  isDarkMode,
                                ),
                              if (_userProfile!.heightCm != null)
                                _buildDetailRow(
                                  context,
                                  Icons.height,
                                  'Height',
                                  '${_userProfile!.heightCm!.toStringAsFixed(0)} cm',
                                  isDarkMode,
                                ),
                              // Corrected: Use locationZipCode instead of locationCity/locationState
                              if (_userProfile!.locationZipCode != null && _userProfile!.locationZipCode!.isNotEmpty)
                                _buildDetailRow(
                                  context,
                                  Icons.location_on,
                                  'Location',
                                  _userProfile!.locationZipCode!,
                                  isDarkMode,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Interests Section
                          if ((_userProfile!.hobbiesAndInterests ?? []).isNotEmpty || (_userProfile!.interests ?? []).isNotEmpty)
                            _buildProfileDetailCard(
                              context,
                              isDarkMode,
                              'Interests',
                              [
                                _buildDetailRow(
                                  context,
                                  Icons.interests,
                                  'Hobbies',
                                  // Prefer hobbiesAndInterests, fallback to interests, then empty list
                                  (_userProfile!.hobbiesAndInterests ?? _userProfile!.interests ?? []).join(', '),
                                  isDarkMode,
                                ),
                              ],
                            ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Relationship & Preferences Section
                          _buildProfileDetailCard(
                            context,
                            isDarkMode,
                            'Relationship & Preferences',
                            [
                              if (_userProfile!.sexualOrientation != null)
                                _buildDetailRow(
                                  context,
                                  Icons.favorite_border,
                                  'Sexual Orientation',
                                  _userProfile!.sexualOrientation!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.lookingFor != null)
                                _buildDetailRow(
                                  context,
                                  Icons.search,
                                  'Looking For',
                                  _userProfile!.lookingFor!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.maritalStatus != null)
                                _buildDetailRow(
                                  context,
                                  Icons.people_alt,
                                  'Marital Status',
                                  _userProfile!.maritalStatus!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.hasChildren != null)
                                _buildDetailRow(
                                  context,
                                  Icons.child_care,
                                  'Has Children',
                                  _userProfile!.hasChildren! ? 'Yes' : 'No',
                                  isDarkMode,
                                ),
                              if (_userProfile!.wantsChildren != null)
                                _buildDetailRow(
                                  context,
                                  Icons.family_restroom,
                                  'Wants Children',
                                  _userProfile!.wantsChildren! ? 'Yes' : 'No',
                                  isDarkMode,
                                ),
                              if (_userProfile!.relationshipGoals != null)
                                _buildDetailRow(
                                  context,
                                  Icons.handshake,
                                  'Relationship Goals',
                                  _userProfile!.relationshipGoals!,
                                  isDarkMode,
                                ),
                              if ((_userProfile!.dealbreakers ?? []).isNotEmpty)
                                _buildDetailRow(
                                  context,
                                  Icons.block,
                                  'Dealbreakers',
                                  (_userProfile!.dealbreakers ?? []).join(', '),
                                  isDarkMode,
                                ),
                              if (_userProfile!.monogamyVsPolyamoryPreferences != null)
                                _buildDetailRow(
                                  context,
                                  Icons.group,
                                  'Monogamy/Polyamory',
                                  _userProfile!.monogamyVsPolyamoryPreferences!,
                                  isDarkMode,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Lifestyle & Values Section
                          _buildProfileDetailCard(
                            context,
                            isDarkMode,
                            'Lifestyle & Values',
                            [
                              if ((_userProfile!.languagesSpoken ?? []).isNotEmpty)
                                _buildDetailRow(
                                  context,
                                  Icons.language,
                                  'Languages',
                                  (_userProfile!.languagesSpoken ?? []).join(', '),
                                  isDarkMode,
                                ),
                              if (_userProfile!.ethnicity != null)
                                _buildDetailRow(
                                  context,
                                  Icons.diversity_3,
                                  'Ethnicity',
                                  _userProfile!.ethnicity!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.religionOrSpiritualBeliefs != null)
                                _buildDetailRow(
                                  context,
                                  Icons.church,
                                  'Religion/Beliefs',
                                  _userProfile!.religionOrSpiritualBeliefs!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.politicalViews != null)
                                _buildDetailRow(
                                  context,
                                  Icons.gavel,
                                  'Political Views',
                                  _userProfile!.politicalViews!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.diet != null)
                                _buildDetailRow(
                                  context,
                                  Icons.restaurant,
                                  'Diet',
                                  _userProfile!.diet!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.smokingHabits != null)
                                _buildDetailRow(
                                  context,
                                  Icons.smoking_rooms,
                                  'Smoking',
                                  _userProfile!.smokingHabits!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.drinkingHabits != null)
                                _buildDetailRow(
                                  context,
                                  Icons.local_bar,
                                  'Drinking',
                                  _userProfile!.drinkingHabits!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.exerciseFrequencyOrFitnessLevel != null)
                                _buildDetailRow(
                                  context,
                                  Icons.fitness_center,
                                  'Exercise',
                                  _userProfile!.exerciseFrequencyOrFitnessLevel!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.sleepSchedule != null)
                                _buildDetailRow(
                                  context,
                                  Icons.bedtime,
                                  'Sleep Schedule',
                                  _userProfile!.sleepSchedule!,
                                  isDarkMode,
                                ),
                              if ((_userProfile!.personalityTraits ?? []).isNotEmpty)
                                _buildDetailRow(
                                  context,
                                  Icons.psychology,
                                  'Personality',
                                  (_userProfile!.personalityTraits ?? []).join(', '),
                                  isDarkMode,
                                ),
                              if (_userProfile!.willingToRelocate != null)
                                _buildDetailRow(
                                  context,
                                  Icons.location_city,
                                  'Willing to Relocate',
                                  _userProfile!.willingToRelocate! ? 'Yes' : 'No',
                                  isDarkMode,
                                ),
                              if (_userProfile!.astrologicalSign != null)
                                _buildDetailRow(
                                  context,
                                  Icons.star,
                                  'Astrological Sign',
                                  _userProfile!.astrologicalSign!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.attachmentStyle != null)
                                _buildDetailRow(
                                  context,
                                  Icons.handshake,
                                  'Attachment Style',
                                  _userProfile!.attachmentStyle!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.communicationStyle != null)
                                _buildDetailRow(
                                  context,
                                  Icons.chat,
                                  'Communication Style',
                                  _userProfile!.communicationStyle!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.mentalHealthDisclosures != null)
                                _buildDetailRow(
                                  context,
                                  Icons.healing,
                                  'Mental Health',
                                  _userProfile!.mentalHealthDisclosures!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.petOwnership != null)
                                _buildDetailRow(
                                  context,
                                  Icons.pets,
                                  'Pet Ownership',
                                  _userProfile!.petOwnership!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.travelFrequencyOrFavoriteDestinations != null)
                                _buildDetailRow(
                                  context,
                                  Icons.travel_explore,
                                  'Travel',
                                  _userProfile!.travelFrequencyOrFavoriteDestinations!,
                                  isDarkMode,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),

                          // Education & Career Section
                          _buildProfileDetailCard(
                            context,
                            isDarkMode,
                            'Education & Career',
                            [
                              if (_userProfile!.educationLevel != null)
                                _buildDetailRow(
                                  context,
                                  Icons.school,
                                  'Education',
                                  _userProfile!.educationLevel!,
                                  isDarkMode,
                                ),
                              if (_userProfile!.desiredOccupation != null)
                                _buildDetailRow(
                                  context,
                                  Icons.work,
                                  'Occupation',
                                  _userProfile!.desiredOccupation!,
                                  isDarkMode,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileDetailCard(BuildContext context, bool isDarkMode, String title, List<Widget> children) {
    if (children.isEmpty) {
      return const SizedBox.shrink(); // Don't show card if no content
    }
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      color: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  ),
            ),
            const Divider(height: AppConstants.spacingMedium, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String content, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor, size: 20),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}