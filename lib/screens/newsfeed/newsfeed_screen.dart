// lib/screens/newsfeed/newsfeed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

import 'package:bliindaidating/services/newsfeed_service.dart';
import 'package:bliindaidating/services/profile_service.dart';
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  List<String> _newsfeedItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('NewsfeedScreen: initState START.');
    _fetchNewsfeedItems(); // Fetch newsfeed items from the backend
    debugPrint('NewsfeedScreen: initState END.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('NewsfeedScreen: didChangeDependencies called.');
    // If you access any InheritedWidgets or Providers here, this is where it happens.
  }

  Future<void> _fetchNewsfeedItems() async {
    debugPrint('NewsfeedScreen: _fetchNewsfeedItems START. Setting isLoading to true.');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Accessing NewsfeedService and ProfileService.');
      final newsfeedService = Provider.of<NewsfeedService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      final currentUserProfile = profileService.userProfile;
      final String userProfileSummary = currentUserProfile?.bio ?? "A user on the dating app.";
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - User profile summary: "$userProfileSummary"');

      final List<Map<String, dynamic>> recentActivity = [
        {"type": "liked_profile", "target_display_name": "Alex"},
        {"type": "new_match", "target_display_name": "Jordan"},
        {"type": "viewed_event", "event_name": "Stargazing Night"},
      ];
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Using mock recent activity: $recentActivity');


      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Calling newsfeedService.refreshNewsfeed.');
      final List<String> items = await newsfeedService.refreshNewsfeed(
        userProfileSummary,
        recentActivity,
      );
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems - newsfeedService.refreshNewsfeed COMPLETED. Items received: ${items.length}');
      setState(() {
        _newsfeedItems = items;
        debugPrint('NewsfeedScreen: _fetchNewsfeedItems - _newsfeedItems updated via setState. Current count: ${_newsfeedItems.length}');
      });
    } catch (e) {
      debugPrint('NewsfeedScreen: ERROR fetching newsfeed items: $e');
      setState(() {
        _errorMessage = 'Failed to load newsfeed: ${e.toString()}';
        debugPrint('NewsfeedScreen: _fetchNewsfeedItems - Error message set: $_errorMessage');
      });
    } finally {
      debugPrint('NewsfeedScreen: _fetchNewsfeedItems FINALLY block. Setting isLoading to false.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NewsfeedScreen: build START.');
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    debugPrint('NewsfeedScreen: build - isDarkMode: $isDarkMode, _isLoading: $_isLoading, _errorMessage: $_errorMessage, _newsfeedItems.isEmpty: ${_newsfeedItems.isEmpty}');


    if (_isLoading) {
      debugPrint('NewsfeedScreen: build - Displaying LoadingIndicatorWidget.');
      return Center(
        child: LoadingIndicatorWidget(
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    if (_errorMessage != null) {
      debugPrint('NewsfeedScreen: build - Displaying error message: $_errorMessage.');
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

    if (_newsfeedItems.isEmpty) {
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

    debugPrint('NewsfeedScreen: build - Displaying ListView of newsfeed items. Item count: ${_newsfeedItems.length}');
    return RefreshIndicator(
      onRefresh: () {
        debugPrint('NewsfeedScreen: RefreshIndicator triggered. Calling _fetchNewsfeedItems.');
        return _fetchNewsfeedItems(); // Return the Future from the async function
      },
      color: AppConstants.primaryColor,
      backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _newsfeedItems.length,
        itemBuilder: (context, index) {
          final item = _newsfeedItems[index];
          debugPrint('NewsfeedScreen: ListView.builder - building item $index: "$item"');
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
                  Text(
                    item,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    // debugPrint('NewsfeedScreen: build END.'); // Cannot place after return
  }

  @override
  void dispose() {
    debugPrint('NewsfeedScreen: dispose called.');
    super.dispose();
  }
}