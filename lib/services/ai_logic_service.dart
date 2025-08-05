// lib/services/ai_logic_service.dart

import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Import the http package
import 'package:flutter/foundation.dart'; // For debugPrint
import '../app_constants.dart'; // Import AppConstants for the base URL

/// A service responsible for all AI-related logic,
/// acting as an intermediary to a backend API that wraps external AI models.
class AiLogicService {
  // The base URL for your FastAPI backend (or other backend)
  // We'll clean this up to ensure no trailing slash
  final String _baseUrl = AppConstants.baseUrl.endsWith('/')
      ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
      : AppConstants.baseUrl;

  // Existing method to generate news feed
  Future<List<String>?> generateNewsFeed(String userProfileSummary, List<Map<String, dynamic>> recentActivity, {int numItems = 3}) async {
    final url = Uri.parse('$_baseUrl/generate-news-feed/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_profile_summary': userProfileSummary,
      'recent_activity': recentActivity,
      'num_items': numItems,
    });

    debugPrint('AiLogicService: Requesting news feed generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['news_feed_items'] is List) {
          final List<String> newsFeedItems = List<String>.from(data['news_feed_items'].map((item) => item.toString()));
          debugPrint('AiLogicService: News feed items generated successfully (${newsFeedItems.length} items).');
          return newsFeedItems;
        }
        debugPrint('AiLogicService: News feed items returned in unexpected format from backend: ${response.body}');
        return null;
      } else {
        debugPrint('Failed to generate news feed from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating news feed via backend: $e');
      return null;
    }
  }

  // UPDATED: Corrected URL to match the new backend endpoint.
  Future<List<Map<String, dynamic>>?> getAiGeneratedMatches(String userProfileSummary, {int numMatches = 5}) async {
    // Corrected URL construction
    final url = Uri.parse('$_baseUrl/generate-ai-matches/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_profile_summary': userProfileSummary,
      'num_matches': numMatches,
    });

    debugPrint('AiLogicService: Requesting AI-generated matches from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['matches'] is List) {
          final List<Map<String, dynamic>> matches = List<Map<String, dynamic>>.from(data['matches']);
          debugPrint('AiLogicService: AI-generated matches retrieved successfully (${matches.length} items).');
          return matches;
        }
        debugPrint('AiLogicService: Matches returned in unexpected format from backend: ${response.body}');
        return null;
      } else {
        debugPrint('Failed to retrieve matches from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving matches via backend: $e');
      return null;
    }
  }

  // UPDATED: Corrected URL to match the new backend endpoint.
  Future<List<Map<String, dynamic>>?> getAiGeneratedDates(String userProfileSummary, {int numDates = 3}) async {
    // Corrected URL construction
    final url = Uri.parse('$_baseUrl/generate-ai-dates/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_profile_summary': userProfileSummary,
      'num_dates': numDates,
    });

    debugPrint('AiLogicService: Requesting AI-generated dates from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['dates'] is List) {
          final List<Map<String, dynamic>> dates = List<Map<String, dynamic>>.from(data['dates']);
          debugPrint('AiLogicService: AI-generated dates retrieved successfully (${dates.length} items).');
          return dates;
        }
        debugPrint('AiLogicService: Dates returned in unexpected format from backend: ${response.body}');
        return null;
      } else {
        debugPrint('Failed to retrieve dates from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving dates via backend: $e');
      return null;
    }
  }

  // UPDATED: Corrected method to use a POST request as per the backend.
  Future<String?> generateDailyPrompt({String? context}) async {
    final url = Uri.parse('$_baseUrl/generate-daily-prompt/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'context': context,
    });

    debugPrint('AiLogicService: Requesting daily prompt generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? prompt = data['daily_prompt'] as String?; // The backend key is 'daily_prompt'
        debugPrint('AiLogicService: Daily prompt generated successfully.');
        return prompt;
      } else {
        debugPrint('Failed to generate daily prompt from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating daily prompt via backend: $e');
      return null;
    }
  }

  Future<String?> generateProfileBio(Map<String, String> userData, {String? instructions}) async {
    final url = Uri.parse('$_baseUrl/generate-profile/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_data': userData,
      'prompt_instructions': instructions,
    });

    debugPrint('AiLogicService: Requesting profile bio generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? profileBio = data['profile_bio'] as String?;
        debugPrint('AiLogicService: Profile bio generated successfully.');
        return profileBio;
      } else {
        debugPrint('Failed to generate profile bio: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating profile bio: $e');
      return null;
    }
  }
}
