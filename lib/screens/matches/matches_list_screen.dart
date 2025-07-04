import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:provider/provider.dart'; // Import provider for theme
import 'package:bliindaidating/app_constants.dart'; // Import app_constants
import 'package:bliindaidating/controllers/theme_controller.dart'; // Import theme controller
import 'package:bliindaidating/models/user_profile.dart'; // Assume you have a UserProfile model
// import 'package:bliindaidating/services/match_service.dart'; // Uncomment and use for real data

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  // Sample list of matches. In a real app, these would be UserProfile objects fetched from a service.
  // For demonstration, let's use a dummy structure that includes a pseudo-ID.
  List<Map<String, dynamic>> _matches = [
    {'name': 'Alice', 'id': 'user_alice_123', 'subtitle': 'You have a mutual interest!'},
    {'name': 'Bob', 'id': 'user_bob_456', 'subtitle': 'Great compatibility!'},
    {'name': 'Charlie', 'id': 'user_charlie_789', 'subtitle': 'Similar hobbies!'},
  ];

  bool _isLoading = false; // To show loading state if fetching real matches
  String? _errorMessage; // To show error if fetching fails

  @override
  void initState() {
    super.initState();
    // In a real app, you would call a match service here
    // _fetchMatches();
  }

  // Example of a dummy fetch function
  // Future<void> _fetchMatches() async {
  //   setState(() { _isLoading = true; _errorMessage = null; });
  //   try {
  //     // Replace with actual API call
  //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  //     // List<UserProfile> fetchedMatches = await MatchService().fetchMyMatches();
  //     // setState(() {
  //     //   _matches = fetchedMatches.map((p) => {'name': p.displayName, 'id': p.userId, 'subtitle': 'Your compatibility message'}).toList();
  //     //   _isLoading = false;
  //     // });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Failed to load matches: ${e.toString()}';
  //       _isLoading = false;
  //     });
  //   }
  // }

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

    if (_matches.isEmpty) {
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
        backgroundColor: Colors.transparent, // AppBar is typically handled by DashboardAppBar in shell
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
                  // Navigate to the profile view screen using GoRouter
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