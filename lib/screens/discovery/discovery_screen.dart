import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
// import 'package:bliindaidating/services/openai_service.dart'; // No longer directly used for data fetching
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data
import 'dart:ui'; // For ImageFilter.blur

import 'package:bliindaidating/widgets/profile/profile_discovery_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // Removed OpenAIService instance
  List<UserProfile> _discoverableProfiles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDummyDiscoverableProfiles(); // Call local dummy data loader
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadDummyDiscoverableProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _discoverableProfiles = dummyDiscoveryProfiles; // Use hardcoded dummy data
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dummy discoverable profiles: $e');
      setState(() {
        _errorMessage = 'Failed to load profiles: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<UserProfile> get _filteredProfiles {
    if (_searchQuery.isEmpty) {
      return _discoverableProfiles;
    }
    final queryLower = _searchQuery.toLowerCase();
    return _discoverableProfiles.where((profile) {
      // Search by display name, full name, or interests
      final displayName = profile.displayName?.toLowerCase() ?? '';
      final fullName = profile.fullLegalName?.toLowerCase() ?? ''; // Changed to fullLegalName as fullName is less certain for search
      // Corrected: Use hobbiesAndInterests directly as it's a List<String>
      final interests = profile.hobbiesAndInterests.map((i) => i.toLowerCase()).join(' ');
      return displayName.contains(queryLower) ||
             fullName.contains(queryLower) ||
             interests.contains(queryLower);
    }).toList();
  }

  void _onLikeProfile(UserProfile profile) {
    // TODO: Implement actual like logic (e.g., store in a local list, send to backend later)
    debugPrint('Liked profile: ${profile.displayName ?? profile.fullLegalName}'); // Changed to fullLegalName
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You liked ${profile.displayName ?? "this user"}! (Dummy)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search people by name or interests...',
              hintStyle: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis),
              labelStyle: TextStyle(color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis),
              prefixIcon: Icon(Icons.search, color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: BorderSide(color: isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: BorderSide(color: isDarkMode ? AppConstants.borderColor : AppConstants.lightBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: BorderSide(color: AppConstants.secondaryColor, width: 2.0),
              ),
              filled: true,
              fillColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            ),
            style: TextStyle(color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppConstants.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _filteredProfiles.isEmpty
                      ? Center(
                          child: Text(
                            'No profiles found matching your search.',
                            style: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                            childAspectRatio: 0.8, // Adjust as needed for card size
                            crossAxisSpacing: AppConstants.spacingMedium,
                            mainAxisSpacing: AppConstants.spacingMedium,
                          ),
                          itemCount: _filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = _filteredProfiles[index];
                            return ProfileDiscoveryCard(
                              profile: profile,
                              onLike: () => _onLikeProfile(profile),
                              isDarkMode: isDarkMode,
                            );
                          },
                        ),
        ),
      ],
    );
  }
}