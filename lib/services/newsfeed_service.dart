// lib/services/newsfeed_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart'; // Still import for NewsfeedItemType
import 'dart:convert'; // For jsonEncode, jsonDecode
// REMOVE THIS: import 'package:http/http.dart' as http; // No longer making direct HTTP requests here

import 'package:bliindaidating/services/ai_logic_service.dart'; // <--- IMPORT AiLogicService

/// A service to manage newsfeed items, including AI generation.
class NewsfeedService extends ChangeNotifier {
  List<String> _newsfeedItems = []; // Now stores strings from LLM
  List<String> get newsfeedItems => _newsfeedItems;

  // Inject AiLogicService (or create an instance)
  final AiLogicService _aiLogicService; // <--- ADD THIS

  // CORRECTED CONSTRUCTOR SYNTAX
  NewsfeedService({AiLogicService? aiLogicService})
      : _aiLogicService = aiLogicService ?? AiLogicService(); // <-- No curly brace immediately after this line
  // If you needed a body, it would look like this:
  // {
  //   // Any additional constructor logic here
  //   debugPrint('NewsfeedService initialized.');
  // }
  // Since you only have a comment there, you can omit the body entirely.
  // We won't fetch on init here, as newsfeed_screen calls refreshNewsfeed


  // This method generates newsfeed items using an LLM (via AiLogicService)
  Future<List<String>> generateNewsFeedItems(
      String userProfileSummary,
      List<Map<String, dynamic>> recentActivity,
      {int numItems = 3}) async {
    debugPrint('NewsfeedService: Requesting newsfeed items from AiLogicService...');
    try {
      // Call the AiLogicService to get the newsfeed items.
      // AiLogicService (or your backend it calls) should handle the JSON parsing and markdown stripping.
      final List<String>? generatedItems = await _aiLogicService.generateNewsFeed(
        userProfileSummary,
        recentActivity,
        numItems: numItems,
      );

      if (generatedItems != null && generatedItems.isNotEmpty) {
        _newsfeedItems = generatedItems;
        debugPrint('NewsfeedService: Received ${_newsfeedItems.length} newsfeed items from AiLogicService.');
      } else {
        debugPrint('NewsfeedService: AiLogicService returned no newsfeed items.');
        _newsfeedItems = ['Failed to generate newsfeed items. Please try again later.'];
      }
      notifyListeners();
      return _newsfeedItems;

    } catch (e) {
      debugPrint('Error calling AiLogicService for newsfeed generation: $e');
      _newsfeedItems = ['Error generating newsfeed: ${e.toString()}'];
      notifyListeners();
      return _newsfeedItems;
    }
  }

  // Method to refresh newsfeed (calls the generation method)
  Future<List<String>> refreshNewsfeed(String userProfileSummary, List<Map<String, dynamic>> recentActivity) async {
    return await generateNewsFeedItems(userProfileSummary, recentActivity);
  }
}