// lib/services/match_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile model

class MatchService {
  final String _baseUrl = AppConstants.baseUrl;

  /// Fetches a list of matched user profiles for a given user ID.
  /// This assumes a new backend endpoint like /find-matches/{user_id}
  Future<List<UserProfile>> findMatches(String userId, {int limit = 10, int offset = 0}) async {
    final url = Uri.parse('$_baseUrl/find-matches/$userId?limit=$limit&offset=$offset');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['matches'] is List) {
          return List<UserProfile>.from(
            (data['matches'] as List).map((json) => UserProfile.fromJson(json))
          );
        }
        debugPrint('Backend returned unexpected format for /find-matches: ${response.body}');
        return [];
      } else {
        debugPrint('Failed to fetch matches: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      return [];
    }
  }
}