// lib/screens/dashboard/suggested_profiles_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider for accessing services
import 'package:bliindaidating/models/user_profile.dart'; // Import your UserProfile model
import 'package:bliindaidating/services/match_service.dart'; // Import your MatchService
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService to get current user ID
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this
import 'package:bliindaidating/app_constants.dart'; // For colors and spacing

class SuggestedProfilesScreen extends StatefulWidget {
  const SuggestedProfilesScreen({super.key});

  @override
  State<SuggestedProfilesScreen> createState() => _SuggestedProfilesScreenState();
}

class _SuggestedProfilesScreenState extends State<SuggestedProfilesScreen> {
  List<UserProfile> _suggestedProfiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSuggestedProfiles(); // Fetch suggested profiles when the screen initializes
  }

  Future<void> _fetchSuggestedProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final matchService = Provider.of<MatchService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // IMPORTANT: Replace with the actual ID of the current logged-in user
      // For testing, you might use a hardcoded dummy user ID that exists in your Supabase.
      // In a real app, this would come from your AuthService (e.g., Supabase.instance.client.auth.currentUser?.id)
      final String? currentUserId = profileService.userProfile?.userId; // Get current user from ProfileService

      if (currentUserId == null) {
        setState(() {
          _error = 'No current user logged in to find matches for. Please log in or generate a test user.';
        });
        return;
      }

      // Fetch suggested profiles (matches) from your backend via MatchService
      final matches = await matchService.findMatches(currentUserId, limit: 10);
      setState(() {
        _suggestedProfiles = matches;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load suggested profiles: $e';
        debugPrint('Error fetching suggested profiles: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Profiles'),
        backgroundColor: AppConstants.primaryColorShade900,
        foregroundColor: AppConstants.textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchSuggestedProfiles,
            tooltip: 'Refresh Suggested Profiles',
          ),
        ],
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: _isLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: theme.textTheme.titleMedium?.copyWith(color: AppConstants.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      ElevatedButton(
                        onPressed: _fetchSuggestedProfiles,
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
                )
              : _suggestedProfiles.isEmpty
                  ? Center(
                      child: EmptyStateWidget(
                        message: 'No suggested profiles found. Try generating more dummy users or adjusting your preferences!',
                        onRefresh: _fetchSuggestedProfiles,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _suggestedProfiles.length,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemBuilder: (context, index) {
                        final userProfile = _suggestedProfiles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                            border: Border.all(color: AppConstants.borderColor.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Picture
                              if (userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                                    child: CircleAvatar(
                                      radius: AppConstants.avatarRadius * 1.5,
                                      backgroundImage: NetworkImage(userProfile.profilePictureUrl!),
                                      backgroundColor: AppConstants.surfaceColor,
                                    ),
                                  ),
                                ),
                              // Display Name
                              Text(
                                userProfile.displayName ?? userProfile.fullLegalName ?? 'Anonymous User',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppConstants.textHighEmphasis,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppConstants.fontSizeLarge,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              // Bio
                              Text(
                                '"${userProfile.bio ?? 'No bio provided.'}"',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppConstants.textLowEmphasis,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),
                              // Hobbies and Interests
                              if (userProfile.hobbiesAndInterests.isNotEmpty)
                                Wrap(
                                  spacing: AppConstants.spacingSmall,
                                  runSpacing: AppConstants.spacingExtraSmall,
                                  children: userProfile.hobbiesAndInterests.map((hobby) => Chip(
                                    label: Text(hobby, style: theme.textTheme.bodySmall?.copyWith(color: AppConstants.textColor)),
                                    backgroundColor: AppConstants.secondaryColor.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
                                  )).toList(),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}