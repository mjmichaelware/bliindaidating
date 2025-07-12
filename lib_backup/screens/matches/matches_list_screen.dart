import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data for profiles
import 'package:uuid/uuid.dart'; // Still needed for generating dummy match IDs if not directly from dummyDiscoveryProfiles

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true; // Set to true initially to show loading
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDummyMatches(); // Load dummy matches from dummy data
  }

  Future<void> _loadDummyMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      // Create dummy matches using IDs from dummyDiscoveryProfiles
      // This ensures that when "View Profile" is clicked, the ID exists in dummyDiscoveryProfiles
      List<Map<String, dynamic>> generatedMatches = [];
      if (dummyDiscoveryProfiles.length >= 3) { // Ensure enough profiles to create matches
        generatedMatches.add({
          'name': dummyDiscoveryProfiles?[0].displayName ?? dummyDiscoveryProfiles?[0].fullName,
          'id': dummyDiscoveryProfiles?[0].id,
          'subtitle': 'You have a mutual interest!',
        });
        generatedMatches.add({
          'name': dummyDiscoveryProfiles?[1].displayName ?? dummyDiscoveryProfiles?[1].fullName,
          'id': dummyDiscoveryProfiles?[1].id,
          'subtitle': 'Great compatibility!',
        });
        generatedMatches.add({
          'name': dummyDiscoveryProfiles?[2].displayName ?? dummyDiscoveryProfiles?[2].fullName,
          'id': dummyDiscoveryProfiles?[2].id,
          'subtitle': 'Similar hobbies!',
        });
      } else {
        // Fallback if not enough dummy profiles
        generatedMatches.add({'name': 'Dummy Match 1', 'id': const Uuid().v4(), 'subtitle': 'A placeholder match'});
      }

      setState(() {
        _matches = generatedMatches;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dummy matches: $e');
      setState(() {
        _errorMessage = 'Failed to load matches: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: AppConstants.errorColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    if ((_matches ?? []).isEmpty) {
      return Center(
        child: Text(
          'No matches found yet.',
          style: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis),
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
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Card(
            margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
            color: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDarkMode ? AppConstants.secondaryColor.withOpacity(0.2) : AppConstants.lightSecondaryColor.withOpacity(0.5),
                child: Icon(Icons.person, color: isDarkMode ? AppConstants.secondaryColor : AppConstants.secondaryColorShade900),
              ),
              title: Text(
                match['name']!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                match['subtitle']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  if (match['id'] != null) {
                    context.push('/profile/${match['id']}');
                    debugPrint('Navigating to profile of ${match['name']} with ID: ${match['id']}');
                  } else {
                    debugPrint('Match ID is null for ${match['name']}');
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