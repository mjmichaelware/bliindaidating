// lib/screens/newsfeed/newsfeed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/widgets/newsfeed/newsfeed_card.dart';
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('NewsfeedScreen: initState START. Requesting news feed fetch...');
    // Request a data fetch only when the screen is first initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNewsfeedItems();
    });
    debugPrint('NewsfeedScreen: initState END.');
  }

  Future<void> _fetchNewsfeedItems() async {
    final newsfeedService = Provider.of<NewsfeedService>(context, listen: false);

    // Only fetch if the service is not already loading
    if (newsfeedService.isLoading) {
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems skipped because service is already loading.');
      return;
    }
    
    final session = Supabase.instance.client.auth.currentSession;
    final jwtToken = session?.accessToken;

    if (jwtToken == null) {
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - User not authenticated.');
      return;
    }
    
    // Using dummy data for now
    const String userProfileSummary = "A 25-year-old software engineer who enjoys hiking and playing guitar.";
    final List<Map<String, dynamic>> recentActivity = [
      {"type": "liked_profile", "target_display_name": "Alex"},
      {"type": "new_match", "target_display_name": "Jordan"},
    ];

    debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Calling newsfeedService.refreshNewsfeed.');
    try {
      await newsfeedService.refreshNewsfeed(
        userProfileSummary,
        recentActivity,
        jwtToken,
      );
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - refreshNewsfeed completed.');
    } catch (e) {
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Error during fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NewsfeedScreen: build START.');
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Consumer<NewsfeedService>(
      builder: (context, newsfeedService, child) {
        if (newsfeedService.isLoading) {
          debugPrint('NewsfeedScreen: build - Displaying LoadingIndicatorWidget.');
          return Center(
            child: LoadingIndicatorWidget(
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }

        if (newsfeedService.errorMessage != null) {
          debugPrint('NewsfeedScreen: build - Displaying error message: ${newsfeedService.errorMessage}.');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  newsfeedService.errorMessage!,
                  style: TextStyle(color: AppConstants.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('NewsfeedScreen: "Try Again" button pressed. Calling _fetchNewsfeedItems.');
                    _fetchNewsfeedItems();
                  },
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

        if (newsfeedService.newsfeedItems.isEmpty) {
          debugPrint('NewsfeedScreen: build - Displaying EmptyStateWidget (no items).');
          return Center(
            child: EmptyStateWidget(
              message: 'No newsfeed items to display yet. Check back later!',
              onRefresh: () {
                debugPrint('NewsfeedScreen: EmptyStateWidget refresh button pressed. Calling _fetchNewsfeedItems.');
                _fetchNewsfeedItems();
              },
              icon: Icons.rss_feed,
            ),
          );
        }

        debugPrint('NewsfeedScreen: build - Displaying ListView of newsfeed items. Item count: ${newsfeedService.newsfeedItems.length}');
        return RefreshIndicator(
          onRefresh: () => _fetchNewsfeedItems(),
          color: AppConstants.primaryColor,
          backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: newsfeedService.newsfeedItems.length,
            itemBuilder: (context, index) {
              final NewsfeedItem item = newsfeedService.newsfeedItems[index];
              debugPrint('NewsfeedScreen: ListView.builder - building item $index: "$item"');
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                ),
                child: NewsfeedCard(
                  content: item,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrint('NewsfeedScreen: dispose called.');
    super.dispose();
  }
}