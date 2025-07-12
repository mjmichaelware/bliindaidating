import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
// import 'package:bliindaidating/services/openai_service.dart'; // No longer directly used for data fetching
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  // Removed OpenAIService instance
  List<NewsfeedItem> _newsfeedItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDummyNewsfeedItems(); // Call local dummy data loader
  }

  Future<void> _loadDummyNewsfeedItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _newsfeedItems = dummyNewsfeedItems; // Use hardcoded dummy data
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dummy newsfeed items: $e');
      setState(() {
        _errorMessage = 'Failed to load newsfeed: ${e.toString()}';
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

    if ((_newsfeedItems ?? []).isEmpty) {
      return Center(
        child: Text(
          'No newsfeed items to display yet. Check back later!',
          style: TextStyle(color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDummyNewsfeedItems, // Still allow refresh to reload dummy data
      color: AppConstants.primaryColor,
      backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _newsfeedItems.length,
        itemBuilder: (context, index) {
          final item = _newsfeedItems[index];
          // You can create different widgets based on item.type if needed
          return Card(
            margin: EdgeInsets.only(bottom: AppConstants.spacingMedium),
            color: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
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
                    item.title ?? 'Newsfeed Update', // Use the title field
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    item.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingSmall),
                  // Example of displaying username/date if available
                  if (item.username != null || item.timestamp != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '— ${item.username ?? 'System'} ${item.timestamp != null ? 'on ${item.timestamp!.toLocal().toShortString()}' : ''}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDarkMode ? AppConstants.textLowEmphasis : AppConstants.lightTextLowEmphasis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extension to format DateTime to a short string for display (optional)
extension on DateTime {
  String toShortString() {
    return '$month/$day/$year';
  }
}