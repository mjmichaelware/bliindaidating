// lib/screens/matches/matches_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/matches_service.dart';
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';
import 'package:bliindaidating/app_constants.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  @override
  void initState() {
    super.initState();
    // No need to fetch here as MatchesService does it on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        backgroundColor: AppConstants.primaryColorShade900,
        foregroundColor: AppConstants.textColor,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<MatchesService>(
        builder: (context, matchesService, child) {
          if (matchesService.matches.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                message: 'No matches yet. Keep swiping!',
                onRefresh: matchesService.refreshMatches,
              ),
            );
          }

          return ListView.builder(
            itemCount: matchesService.matches.length,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemBuilder: (context, index) {
              final userProfile = matchesService.matches[index];
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.textHighEmphasis,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeLarge,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      'Bio: "${userProfile.bio ?? 'No bio provided.'}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppConstants.textLowEmphasis,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    if (userProfile.hobbiesAndInterests != null && userProfile.hobbiesAndInterests!.isNotEmpty)
                      Wrap(
                        spacing: AppConstants.spacingSmall,
                        runSpacing: AppConstants.spacingExtraSmall,
                        children: userProfile.hobbiesAndInterests!.keys.map((hobby) => Chip(
                          label: Text(hobby, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppConstants.textColor)),
                          backgroundColor: AppConstants.secondaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
                        )).toList(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}