// lib/services/ai_logic_service.dart
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Import the http package
import '../app_constants.dart'; // Import AppConstants for the base URL

class AiLogicService { // Renamed from AiService to match your file name
  final String _baseUrl = AppConstants.baseUrl; // Use the base URL from AppConstants

  // Function to generate a dating profile bio
  Future<String?> generateProfileBio(Map<String, String> userData, {String? instructions}) async {
    final url = Uri.parse('$_baseUrl/generate-profile/'); // Full URL to your FastAPI endpoint
    final headers = {'Content-Type': 'application/json'}; // Specify content type as JSON
    final body = jsonEncode({ // Encode Dart Map to JSON string
      'user_data': userData,
      'prompt_instructions': instructions,
    });

    try {
      final response = await http.post(url, headers: headers, body: body); // Make POST request

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body); // Decode JSON response
        return data['profile_bio']; // Extract the generated bio
      } else {
        // Log or print error details for debugging
        print('Failed to generate profile bio: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      // Catch any network or other exceptions
      print('Error generating profile bio: $e');
      return null;
    }
  }

  // Function to generate news feed items
  Future<List<String>?> generateNewsFeed(String userProfileSummary, List<Map<String, dynamic>> recentActivity, {int numItems = 3}) async {
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
        // Ensure the backend returns a list of strings directly for 'news_feed_items'
        if (data['news_feed_items'] is List) {
          return List<String>.from(data['news_feed_items']);
        }
        print('News feed items returned in unexpected format.');
        return null;
      } else {
        print('Failed to generate news feed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating news feed: $e');
      return null;
    }
  }

  // Function to generate a daily prompt (GET request)
  Future<String?> generateDailyPrompt({String? context}) async {
    final Map<String, dynamic> queryParams = context != null ? {'context': context} : {};
    final url = Uri.parse('$_baseUrl/generate-daily-prompt/').replace(queryParameters: queryParams);

    try {
      final response = await http.get(url); // Make GET request

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['daily_prompt'];
      } else {
        print('Failed to generate daily prompt: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating daily prompt: $e');
      return null;
    }
  }
}