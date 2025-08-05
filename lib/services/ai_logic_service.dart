// lib/services/ai_logic_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../app_constants.dart';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';

/// A service responsible for all AI-related logic,
/// acting as an intermediary to a backend API that wraps external AI models.
class AiLogicService {

  /// A helper function to create a new headers map with the authorization token.
  Map<String, String> _getHeaders(String jwtToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }

  /// Method to generate news feed
  Future<List<Map<String, dynamic>>?> generateNewsFeed(
    String userProfileSummary,
    List<Map<String, dynamic>> recentActivity,
    String jwtToken,
    {int numItems = 3}
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-news-feed');
    final headers = _getHeaders(jwtToken);
    final body = jsonEncode({
      'user_profile_summary': userProfileSummary,
      'recent_activity': recentActivity,
      'num_items': numItems,
    });

    debugPrint('AiLogicService: Requesting news feed generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          final List<Map<String, dynamic>> newsFeedItems = List<Map<String, dynamic>>.from(data);
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

  /// Method to get AI-generated matches
  Future<List<Map<String, dynamic>>?> getAiGeneratedMatches(
    String userProfileSummary,
    String jwtToken,
    {int numMatches = 5}
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-ai-matches');
    final headers = _getHeaders(jwtToken);
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

  /// Method to get AI-generated dates
  Future<List<Map<String, dynamic>>?> getAiGeneratedDates(
    String userProfileSummary,
    String jwtToken,
    {int numDates = 3}
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-ai-dates');
    final headers = _getHeaders(jwtToken);
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

  /// Method to generate a daily prompt
  Future<String?> generateDailyPrompt(String jwtToken, {String? context}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-daily-prompt');
    final headers = _getHeaders(jwtToken);
    final body = jsonEncode({
      'context': context,
    });

    debugPrint('AiLogicService: Requesting daily prompt generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? prompt = data['daily_prompt'] as String?;
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

  /// Method to generate a profile bio
  Future<String?> generateProfileBio(Map<String, String> userData, String jwtToken, {String? instructions}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-profile');
    final headers = _getHeaders(jwtToken);
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