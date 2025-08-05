import 'package:flutter/foundation.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Assuming UserProfile model exists
import 'package:flutter/material.dart';

/// A service to manage user matches.
class MatchesService extends ChangeNotifier {
  AiLogicService _aiLogicService; // FIX: Changed to non-final
  
  // FIX: Corrected constructor to use a named argument
  MatchesService({required AiLogicService aiLogicService})
      : _aiLogicService = aiLogicService;

  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> get matches => _matches;

  // FIX: Added the missing method
  void updateAiLogicService(AiLogicService newAiLogicService) {
    if (_aiLogicService != newAiLogicService) {
      _aiLogicService = newAiLogicService;
      debugPrint('MatchesService: AiLogicService updated.');
    }
  }

  // Placeholder for user profile data (should be fetched from a user service)
  final String _userProfileSummary = "A 25-year-old software engineer who enjoys hiking and playing guitar.";

  Future<void> refreshMatches(String jwtToken) async {
    debugPrint('MatchesService: Attempting to fetch matches...');
    try {
      final List<Map<String, dynamic>>? fetchedMatches = await _aiLogicService.getAiGeneratedMatches(_userProfileSummary, jwtToken);
      
      if (fetchedMatches != null) {
        _matches = fetchedMatches;
      } else {
        _matches = [];
      }
      debugPrint('MatchesService: Fetched ${_matches.length} matches.');
      notifyListeners();
    } catch (e) {
      debugPrint('MatchesService: Failed to refresh matches: $e');
      _matches = [];
      notifyListeners();
      rethrow;
    }
  }
}