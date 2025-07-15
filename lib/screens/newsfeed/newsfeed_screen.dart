// lib/screens/newsfeed/newsfeed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
// Removed: import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart'; // No longer directly using NewsfeedItem model
// Removed: import 'package:bliindaidating/data/dummy_data.dart'; // No longer using dummy data

import 'package:bliindaidating/services/newsfeed_service.dart'; // Import NewsfeedService
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for user data
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  List<String> _newsfeedItems = []; // Changed to List<String> as backend returns strings
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNewsfeedItems(); // Fetch newsfeed items from the backend
  }

  Future<void> _fetchNewsfeedItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final newsfeedService = Provider.of<NewsfeedService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // Get current user's profile summary for AI context
      final currentUserProfile = profileService.userProfile;
      final String userProfileSummary = currentUserProfile?.bio ?? "A user on the dating app.";

      // Mock recent activity for demonstration. In a real app, this would come from
      // your app's activity tracking or Supabase.
      final List<Map<String, dynamic>> recentActivity = [
        {"type": "liked_profile", "target_display_name": "Alex"},
        {"type": "new_match", "target_display_name": "Jordan"},
        {"type": "viewed_event", "event_name": "Stargazing Night"},
      ];

      final items = await newsfeedService.generateNewsFeedItems(
        userProfileSummary,
        recentActivity,
        numItems: 5, // Request 5 items
      );
      setState(() {
        _newsfeedItems = items;
      });
    } catch (e) {
      debugPrint('Error fetching newsfeed items: $e');
      setState(() {
        _errorMessage = 'Failed to load newsfeed: ${e.toString()}';
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
              onPressed: _fetchNewsfeedItems,
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

    if (_newsfeedItems.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No newsfeed items to display yet. Check back later!',
          onRefresh: _fetchNewsfeedItems,
          icon: Icons.rss_feed, // Example icon
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNewsfeedItems, // Now refreshes from backend
      color: AppConstants.primaryColor,
      backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _newsfeedItems.length,
        itemBuilder: (context, index) {
          final item = _newsfeedItems[index];
          return Card(
            margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
            color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assuming the string content is the main news item
                  Text(
                    item, // Display the string directly
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    ),
                  ),
                  // If you later want more structured news items, you'd need a NewsfeedItem model
                  // and parse the backend response into that model.
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Removed: Extension to format DateTime as NewsfeedItem model is no longer directly used here.