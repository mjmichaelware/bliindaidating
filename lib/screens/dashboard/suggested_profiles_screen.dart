// lib/screens/dashboard/suggested_profiles_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/matches_service.dart'; // FIXED: Corrected import to matches_service.dart
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';
import 'package:bliindaidating/app_constants.dart';

class SuggestedProfilesScreen extends StatefulWidget {
  const SuggestedProfilesScreen({super.key});

  @override
  State<SuggestedProfilesScreen> createState() => _SuggestedProfilesScreenState();
}

class _SuggestedProfilesScreenState extends State<SuggestedProfilesScreen> {
  @override
  void initState() {
    super.initState();
    // In a real app, you might have a separate DiscoveryService for suggested profiles
    // For now, we'll use MatchesService as a placeholder for fetching profiles.
    Provider.of<MatchesService>(context, listen: false).refreshMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchesService = Provider.of<MatchesService>(context); // Watch for changes
    final List<UserProfile> suggestedProfiles = matchesService.matches; // Using matches as suggested profiles for now
    final bool isLoading = matchesService.matches.isEmpty && matchesService.hasListeners; // Simple loading check

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Profiles'),
        backgroundColor: AppConstants.primaryColorShade900,
        foregroundColor: AppConstants.textColor,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: isLoading
          ? const Center(child: LoadingIndicatorWidget())
          : suggestedProfiles.isEmpty
              ? Center(
                  child: EmptyStateWidget(
                    message: 'No suggested profiles at the moment. Check back later!',
                    onRefresh: () {
                      matchesService.refreshMatches();
                    },
                  ),
                )
              : ListView.builder(
                  itemCount: suggestedProfiles.length,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemBuilder: (context, index) {
                    final userProfile = suggestedProfiles[index];
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
                          Text(
                            userProfile.displayName ?? userProfile.fullLegalName ?? 'Anonymous User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppConstants.textHighEmphasis,
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Text(
                            'Personality: ${userProfile.personalityTraits.isNotEmpty ? userProfile.personalityTraits.join(', ') : 'N/A'} | Sign: ${userProfile.astrologicalSign ?? 'N/A'}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppConstants.textMediumEmphasis),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Text(
                            '"${userProfile.bio ?? 'No bio provided.'}"',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppConstants.textLowEmphasis,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
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