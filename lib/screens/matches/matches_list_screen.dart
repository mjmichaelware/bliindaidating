// lib/screens/matches/matches_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Keep go_router for navigation
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile
import 'package:bliindaidating/services/match_service.dart'; // Import MatchService
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService to get current user ID
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this

// Removed: import 'package:bliindaidating/data/dummy_data.dart';
// Removed: import 'package:uuid/uuid.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  List<UserProfile> _matchedProfiles = []; // Changed to List<UserProfile>
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatches(); // Fetch matches from the backend
  }

  Future<void> _fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final matchService = Provider.of<MatchService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // Get the current user's ID from ProfileService
      final String? currentUserId = profileService.userProfile?.userId;

      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'No current user logged in to find matches for. Please log in or generate a test user.';
          _isLoading = false;
        });
        return;
      }

      final matches = await matchService.findMatches(currentUserId, limit: 10); // Fetch 10 matches
      setState(() {
        _matchedProfiles = matches;
      });
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      setState(() {
        _errorMessage = 'Failed to load matches: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    if (_isLoading) {
      return Center(
        child: LoadingIndicatorWidget(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: AppConstants.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            ElevatedButton(
              onPressed: _fetchMatches,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: AppConstants.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_matchedProfiles.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No matches found yet. Keep exploring or update your profile!',
          onRefresh: _fetchMatches,
          icon: Icons.favorite_border, // Example icon
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Matches',
          style: TextStyle(
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeExtraLarge,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchMatches,
            tooltip: 'Refresh Matches',
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _matchedProfiles.length,
        itemBuilder: (context, index) {
          final userProfile = _matchedProfiles[index]; // Changed to UserProfile object
          return Card(
            margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
            color: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDarkMode ? AppConstants.secondaryColor.withOpacity(0.2) : AppConstants.lightSecondaryColor.withOpacity(0.5),
                backgroundImage: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(userProfile.profilePictureUrl!) as ImageProvider
                    : null,
                child: userProfile.profilePictureUrl == null || userProfile.profilePictureUrl!.isEmpty
                    ? Icon(Icons.person, color: isDarkMode ? AppConstants.secondaryColor : AppConstants.secondaryColorShade900)
                    : null,
              ),
              title: Text(
                userProfile.displayName ?? userProfile.fullLegalName ?? 'Anonymous Match', // Use UserProfile properties
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                userProfile.bio ?? 'No bio provided.', // Use UserProfile bio as subtitle
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  if (userProfile.userId.isNotEmpty) {
                    context.push('/profile/${userProfile.userId}'); // Use userId for navigation
                    debugPrint('Navigating to profile of ${userProfile.displayName} with ID: ${userProfile.userId}');
                  } else {
                    debugPrint('Match ID is null for ${userProfile.displayName}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not view profile: User ID missing.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall, vertical: AppConstants.paddingExtraSmall),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                ),
                child: Text(
                  'View Profile',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}