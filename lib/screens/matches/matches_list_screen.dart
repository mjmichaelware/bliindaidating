import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/matches_service.dart';
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  // We need to fetch the initial data in initState
  @override
  void initState() {
    super.initState();
    // This fetches data when the screen is first built.
    _fetchMatches();
  }

  // Method to fetch the matches
  Future<void> _fetchMatches() async {
    final session = Supabase.instance.client.auth.currentSession;
    final jwtToken = session?.accessToken;

    if (jwtToken != null) {
      try {
        final matchesService = Provider.of<MatchesService>(context, listen: false);
        await matchesService.refreshMatches(jwtToken);
      } catch (e) {
        debugPrint('Error fetching matches: $e');
      }
    }
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
            final session = Supabase.instance.client.auth.currentSession;
            final jwtToken = session?.accessToken;
            
            return Center(
              child: EmptyStateWidget(
                message: 'No matches yet. Keep swiping!',
                // FIX: Corrected onRefresh to pass the required token
                onRefresh: jwtToken != null ? () => matchesService.refreshMatches(jwtToken) : null,
              ),
            );
          }

          return ListView.builder(
            itemCount: matchesService.matches.length,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemBuilder: (context, index) {
              final Map<String, dynamic> userProfile = matchesService.matches[index];
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
                    // FIX: Using bracket notation to access map values
                    if (userProfile['profile_picture_url'] != null && userProfile['profile_picture_url'].isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                          child: CircleAvatar(
                            radius: AppConstants.avatarRadius * 1.5,
                            backgroundImage: NetworkImage(userProfile['profile_picture_url']!),
                            backgroundColor: AppConstants.surfaceColor,
                          ),
                        ),
                      ),
                    Text(
                      // FIX: Using bracket notation
                      userProfile['display_name'] ?? userProfile['full_legal_name'] ?? 'Anonymous User',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.textHighEmphasis,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeLarge,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      // FIX: Using bracket notation
                      'Bio: "${userProfile['bio'] ?? 'No bio provided.'}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppConstants.textLowEmphasis,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    // FIX: Using bracket notation and handling the type
                    if (userProfile['hobbies_and_interests'] != null && (userProfile['hobbies_and_interests'] as List).isNotEmpty)
                      Wrap(
                        spacing: AppConstants.spacingSmall,
                        runSpacing: AppConstants.spacingExtraSmall,
                        children: (userProfile['hobbies_and_interests'] as List).map((hobby) => Chip(
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