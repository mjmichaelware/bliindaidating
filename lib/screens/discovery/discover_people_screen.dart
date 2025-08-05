// lib/screens/discovery/discover_people_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';
import 'package:bliindaidating/app_constants.dart';

class DiscoverPeopleScreen extends StatefulWidget {
  const DiscoverPeopleScreen({super.key});

  @override
  State<DiscoverPeopleScreen> createState() => _DiscoverPeopleScreenState();
}

class _DiscoverPeopleScreenState extends State<DiscoverPeopleScreen> {
  List<UserProfile> _discoveredProfiles = [];
  bool _isLoading = true;
  String? _error;
  bool _isGeneratingDummyUsers = false;

  @override
  void initState() {
    super.initState();
    // FIX: Defer the initial profile fetch until after the first frame is built.
    // This prevents setState being called during the build phase of its parent/ancestors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDiscoveredProfiles();
    });
  }

  Future<void> _fetchDiscoveredProfiles() async {
    // Only set loading if not already generating dummy users,
    // as generation also implies loading.
    if (!_isGeneratingDummyUsers) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      final profiles = await profileService.fetchAllUserProfiles();
      setState(() {
        _discoveredProfiles = profiles;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profiles: $e';
        debugPrint('Error fetching discovered profiles: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndRefreshDummyUsers() async {
    setState(() {
      _isGeneratingDummyUsers = true;
      _error = null;
    });
    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      final message = await profileService.generateDummyUsers(5);
      debugPrint('Dummy user generation message: $message');
      await _fetchDiscoveredProfiles(); // Will reset _isLoading to false
    } catch (e) {
      setState(() {
        _error = 'Failed to generate dummy users: $e';
        debugPrint('Error generating dummy users: $e');
      });
    } finally {
      setState(() {
        _isGeneratingDummyUsers = false;
        // _isLoading is already set to false by _fetchDiscoveredProfiles if called last.
        // If _fetchDiscoveredProfiles wasn't called (e.g., if it failed very early),
        // ensure _isLoading is reset.
        if (_error != null) { // Only force reset if an error occurred before _fetchDiscoveredProfiles could finish
           _isLoading = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: AppConstants.primaryColorShade900,
        foregroundColor: AppConstants.textColor,
        actions: [
          IconButton(
            icon: _isGeneratingDummyUsers
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.textColor),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isGeneratingDummyUsers ? null : _generateAndRefreshDummyUsers,
            tooltip: 'Generate & Refresh Dummy Users',
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
                        onPressed: _fetchDiscoveredProfiles,
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
              : _discoveredProfiles.isEmpty
                  ? Center(
                      child: EmptyStateWidget(
                        message: 'No profiles to discover yet. Generate some dummy users!',
                        onRefresh: _generateAndRefreshDummyUsers,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _discoveredProfiles.length,
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemBuilder: (context, index) {
                        final userProfile = _discoveredProfiles[index];
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
                                'Sign: ${userProfile.astrologicalSign ?? 'N/A'}',
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
                              if (userProfile.hobbiesAndInterests != null && userProfile.hobbiesAndInterests!.isNotEmpty)
                                Wrap(
                                  spacing: AppConstants.spacingSmall,
                                  runSpacing: AppConstants.spacingExtraSmall,
                                  children: userProfile.hobbiesAndInterests!.keys.map((hobby) => Chip(
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