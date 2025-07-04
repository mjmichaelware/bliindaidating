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
        backgroundColor: isDarkMode ? AppConstants.cardColor.withOpacity(0.7) : AppConstants.lightCardColor.withOpacity(0.7),
        iconTheme: IconThemeData(color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLarge),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppConstants.errorColor, fontSize: AppConstants.fontSizeMedium),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _userProfile == null
                  ? Center(
                      child: Text(
                        'No profile data available.',
                        style: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis, fontSize: AppConstants.fontSizeMedium),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display profile picture
                          Center(
                            child: CircleAvatar(
                              radius: AppConstants.avatarRadius * 1.5,
                              backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
                              backgroundImage: _userProfile!.profilePictureUrl != null
                                  ? NetworkImage(_userProfile!.profilePictureUrl!) as ImageProvider<Object>
                                  : null,
                              child: _userProfile!.profilePictureUrl == null
                                  ? Icon(Icons.person, size: AppConstants.avatarRadius * 2, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor)
                                  : null,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacingLarge),
                          _buildProfileDetail(
                            title: 'Display Name',
                            content: _userProfile!.displayName ?? 'N/A',
                            isDarkMode: isDarkMode,
                          ),
                          _buildProfileDetail(
                            title: 'Full Name',
                            content: _userProfile!.fullName ?? 'N/A',
                            isDarkMode: isDarkMode,
                          ),
                          _buildProfileDetail(
                            title: 'Bio',
                            content: _userProfile!.bio ?? 'No bio provided.',
                            isDarkMode: isDarkMode,
                          ),
                          if (_userProfile!.interests.isNotEmpty)
                            _buildProfileDetail(
                              title: 'Interests',
                              content: _userProfile!.interests.join(', '),
                              isDarkMode: isDarkMode,
                            ),
                          // Add other public fields here from UserProfile
                          // Example (assuming UserProfile has these fields):
                          // if (_userProfile!.gender != null)
                          //   _buildProfileDetail(
                          //     title: 'Gender',
                          //     content: _userProfile!.gender!,
                          //     isDarkMode: isDarkMode,
                          //   ),
                          // if (_userProfile!.age != null)
                          //   _buildProfileDetail(
                          //     title: 'Age',
                          //     content: _userProfile!.age.toString(),
                          //     isDarkMode: isDarkMode,
                          //   ),
                          // if (_userProfile!.location != null)
                          //   _buildProfileDetail(
                          //     title: 'Location',
                          //     content: _userProfile!.location!,
                          //     isDarkMode: isDarkMode,
                          //   ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileDetail({required String title, required String content, required bool isDarkMode}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppConstants.spacingExtraSmall),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}