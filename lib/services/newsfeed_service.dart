// lib/services/newsfeed_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart'; // Still import for NewsfeedItemType
import 'dart:convert'; // For jsonEncode, jsonDecode
import 'package:http/http.dart' as http; // For making HTTP requests

/// A service to manage newsfeed items, including AI generation.
class NewsfeedService extends ChangeNotifier {
  List<String> _newsfeedItems = []; // Now stores strings from LLM
  List<String> get newsfeedItems => _newsfeedItems;

  NewsfeedService() {
    // We won't fetch on init here, as newsfeed_screen calls refreshNewsfeed
  }

  // This method generates newsfeed items using an LLM
  Future<List<String>> generateNewsFeedItems(
      String userProfileSummary,
      List<Map<String, dynamic>> recentActivity,
      {int numItems = 3}) async {
    debugPrint('NewsfeedService: Generating newsfeed items with LLM...');
    try {
      // Construct a detailed prompt for the LLM
      final prompt = """
      Generate a list of ${numItems} concise and engaging newsfeed items for a dating app user.
      Each item should be a single, compelling sentence or a very short paragraph.
      Focus on recent activity, profile completion, and discovery.
      
      User Profile Summary: "$userProfileSummary"
      Recent App Activity: ${jsonEncode(recentActivity)}
      
      Examples of desired output:
      - "You have a new match! Check out Jordan's profile."
      - "Complete your Phase 2 questionnaire to unlock more compatible matches!"
      - "Daily Prompt: What's your ideal weekend getaway?"
      - "Alex just liked your profile! Send them a message."
      - "New local event: 'Stargazing Night' happening this Saturday!"
      
      Return only a JSON array of strings, where each string is a newsfeed item.
      Example: ["Item 1.", "Item 2.", "Item 3."]
      """;

      // Use the provided fetch call structure for LLM interaction
      const apiKey = ""; // Canvas will automatically provide this in runtime
      const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': prompt}]}
          ]
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['candidates'] != null && result['candidates'].isNotEmpty &&
          result['candidates'][0]['content'] != null && result['candidates'][0]['content']['parts'] != null &&
          result['candidates'][0]['content']['parts'].isNotEmpty) {
        final String text = result['candidates'][0]['content']['parts'][0]['text'];
        debugPrint('LLM Raw Response: $text');

        // Attempt to parse the JSON string into a List<String>
        try {
          final dynamic decoded = jsonDecode(text);
          if (decoded is List) {
            _newsfeedItems = List<String>.from(decoded.map((e) => e.toString()));
            notifyListeners();
            debugPrint('NewsfeedService: Generated ${_newsfeedItems.length} newsfeed items via LLM.');
            return _newsfeedItems;
          } else {
            debugPrint('LLM response was not a JSON list: $text');
            // Fallback if LLM doesn't return perfect JSON array
            _newsfeedItems = [text]; // Treat the whole response as one item
            notifyListeners();
            return _newsfeedItems;
          }
        } catch (e) {
          debugPrint('Error parsing LLM response JSON: $e, Raw text: $text');
          _newsfeedItems = [text]; // Fallback if parsing fails
          notifyListeners();
          return _newsfeedItems;
        }
      } else {
        debugPrint('LLM response was empty or malformed or bad status: ${response.statusCode}');
        _newsfeedItems = ['Failed to generate newsfeed items. Please try again.'];
        notifyListeners();
        return _newsfeedItems;
      }
    } catch (e) {
      debugPrint('Error calling LLM for newsfeed: $e');
      _newsfeedItems = ['Error generating newsfeed: $e'];
      notifyListeners();
      return _newsfeedItems;
    }
  }

  // Method to refresh newsfeed (calls the generation method)
  Future<List<String>> refreshNewsfeed(String userProfileSummary, List<Map<String, dynamic>> recentActivity) async {
    return await generateNewsFeedItems(userProfileSummary, recentActivity);
  }
}