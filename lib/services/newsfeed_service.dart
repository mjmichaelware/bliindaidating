// lib/services/newsfeed_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart'; // Assuming you'll have this model

class NewsfeedService {
  final String _baseUrl = AppConstants.baseUrl;

  /// Generates news feed items by calling the backend AI endpoint.
  /// userProfileSummary: A summary of the current user's profile.
  /// recentActivity: A list of recent activities relevant to the news feed.
  /// numItems: The number of news feed items to generate.
  Future<List<String>> generateNewsFeedItems(String userProfileSummary, List<Map<String, dynamic>> recentActivity, {int numItems = 5}) async {
    final url = Uri.parse('$_baseUrl/generate-news-feed/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_profile_summary': userProfileSummary,
      'recent_activity': recentActivity,
      'num_items': numItems,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['news_feed_items'] is List) {
          // Assuming the backend returns a list of strings directly
          return List<String>.from(data['news_feed_items']);
        }
        debugPrint('Backend returned unexpected format for /generate-news-feed: ${response.body}');
        return [];
      } else {
        debugPrint('Failed to generate news feed items: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error generating news feed items: $e');
      return [];
    }
  }

  // You might also add methods here to fetch news feed items from Supabase
  // if you decide to persist them after generation.
  // Future<List<NewsfeedItem>> fetchNewsFeedFromDb(String userId) async { ... }
}