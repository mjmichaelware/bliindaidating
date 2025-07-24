// lib/services/ai_logic_service.dart
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Import the http package
import '../app_constants.dart'; // Import AppConstants for the base URL
import 'package:flutter/foundation.dart'; // For debugPrint

/// A service responsible for all AI-related logic,
/// acting as an intermediary to a backend API that wraps external AI models.
class AiLogicService {
  // The base URL for your FastAPI backend (or other backend)
  // This should point to your Supabase Edge Functions URL
  // e.g., 'https://<your-project-ref>.supabase.co/functions/v1'
  final String _baseUrl = AppConstants.baseUrl;

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
        // Ensure the backend returns a list of strings directly for 'news_feed_items'
        if (data['news_feed_items'] is List) {
          // Ensure each item in the list is treated as a String
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

  // ... (other methods like generateProfileBio, generateDailyPrompt, generateQuestionnaireAnswer remain unchanged)
  Future<String?> generateProfileBio(Map<String, String> userData, {String? instructions}) async {
    final url = Uri.parse('$_baseUrl/generate-profile/'); // Full URL to your FastAPI endpoint
    final headers = {'Content-Type': 'application/json'}; // Specify content type as JSON
    final body = jsonEncode({ // Encode Dart Map to JSON string
      'user_data': userData,
      'prompt_instructions': instructions,
    });

    debugPrint('AiLogicService: Requesting profile bio generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body); // Make POST request

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body); // Decode JSON response
        final String? profileBio = data['profile_bio'] as String?;
        debugPrint('AiLogicService: Profile bio generated successfully.');
        return profileBio; // Extract the generated bio
      } else {
        // Log or print error details for debugging
        debugPrint('Failed to generate profile bio: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // Catch any network or other exceptions
      debugPrint('Error generating profile bio: $e');
      return null;
    }
  }

  /// NEW: Function to generate an AI-suggested answer for a questionnaire question.
  /// This assumes a new backend endpoint `/generate-questionnaire-answer/`
  Future<String?> generateQuestionnaireAnswer(String questionText, Map<String, dynamic> userContext) async {
    final url = Uri.parse('$_baseUrl/generate-questionnaire-answer/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'question_text': questionText,
      'user_context': userContext,
    });

    debugPrint('AiLogicService: Requesting questionnaire answer generation from backend...');
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? answer = data['answer'] as String?; // Assuming backend returns {'answer': 'AI-generated text'}
        debugPrint('AiLogicService: Questionnaire answer generated successfully.');
        return answer;
      } else {
        debugPrint('Failed to generate questionnaire answer from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating questionnaire answer via backend: $e');
      return null;
    }
  }

  // Function to generate a daily prompt (GET request)
  /// Makes a GET request to your backend to generate a daily prompt.
  Future<String?> generateDailyPrompt({String? context}) async {
    final Map<String, dynamic> queryParams = context != null ? {'context': context} : {};
    final url = Uri.parse('$_baseUrl/generate-daily-prompt/').replace(queryParameters: queryParams);

    debugPrint('AiLogicService: Requesting daily prompt generation from backend...');
    try {
      final response = await http.get(url); // Make GET request

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? dailyPrompt = data['daily_prompt'] as String?;
        debugPrint('AiLogicService: Daily prompt generated successfully.');
        return dailyPrompt;
      } else {
        debugPrint('Failed to generate daily prompt from backend: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating daily prompt via backend: $e');
      return null;
    }
  }
}