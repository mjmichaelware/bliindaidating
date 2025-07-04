// lib/services/openai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:bliindaidating/models/user_profile.dart'; // For dummy profiles
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/models/newsfeed/ai_engagement_prompt.dart';
import 'package:uuid/uuid.dart'; // Ensure Uuid is imported

class OpenAIService {
  // This is the URL for your DEPLOYED Supabase Edge Function (match-users), not your local database URL.
  // Based on your earlier provided info, this is your deployed URL.
  final String _supabaseEdgeFunctionUrl = 'https://kynzpohycwdphorxsnzy.supabase.co/functions/v1/match-users';

  // Use SUPABASE_KEY to match the naming convention in your supabase_config.dart and .env file.
  final String _supabaseAnonKey = const String.fromEnvironment(
    'SUPABASE_KEY', // This matches the key name in your .env file
    defaultValue: 'YOUR_SUPABASE_KEY_FROM_DOTENV_OR_DART_DEFINE_HERE', // Placeholder
  ); 

  final Uuid _uuid = const Uuid(); // Instantiate Uuid for ID generation

  OpenAIService() {
    if (_supabaseAnonKey == 'YOUR_SUPABASE_KEY_FROM_DOTENV_OR_DART_DEFINE_HERE' && kDebugMode) {
      debugPrint('WARNING: Supabase Key in OpenAIService is not configured. Please ensure it\'s in .env or passed via --dart-define=SUPABASE_KEY=\'YOUR_KEY\'.');
    }
    debugPrint('OpenAIService initialized with Edge Function URL: $_supabaseEdgeFunctionUrl');
  }

  Future<String> _callEdgeFunction({required String promptText, String? name}) async {
    try {
      final response = await http.post(
        Uri.parse(_supabaseEdgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey', // Use Supabase anon key for authorization
        },
        body: jsonEncode({
          'prompt_text': promptText,
          'name': name ?? 'AIRequest', // Default name if not provided
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Your Edge Function returns 'ai_response'
        return data['ai_response'] ?? 'No AI response received.';
      } else {
        debugPrint('OpenAIService Error: HTTP Status Code ${response.statusCode}');
        debugPrint('OpenAIService Error: Response Body ${response.body}');
        throw Exception('Failed to call Edge Function: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('OpenAIService Exception during Edge Function call: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Error communicating with AI service: ${e.toString()}');
    }
  }

  // Helper to robustly parse JSON from AI responses that might contain extra text
  List<dynamic> _parseAIJsonResponse(String rawResponse) {
    String cleanJson = rawResponse;
    final int firstBracket = rawResponse.indexOf('[');
    final int firstBrace = rawResponse.indexOf('{');
    final int lastBracket = rawResponse.lastIndexOf(']');
    final int lastBrace = rawResponse.lastIndexOf('}');

    if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
      cleanJson = rawResponse.substring(firstBracket, lastBracket + 1);
    } else if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleanJson = '[${rawResponse.substring(firstBrace, lastBrace + 1)}]';
    } else {
      throw FormatException('AI response did not contain a recognizable JSON structure: $rawResponse');
    }

    try {
      final List<dynamic> jsonList = jsonDecode(cleanJson);
      return jsonList;
    } catch (e, stackTrace) {
      debugPrint('Error decoding JSON from AI response: $e');
      debugPrint('Attempted to decode: $cleanJson');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // --- Dummy Data Generation Methods ---

  Future<List<NewsfeedItem>> generateNewsfeedItems(int count, {required String userLocation, required int userRadius}) async {
    final String prompt = '''
      Generate $count diverse newsfeed items for a dating app called BlindAIDating.
      Each item should be a JSON object and include:
      "id" (unique string, e.g., "${_uuid.v4()}"),
      "type" (string, enum: "date_success", "match_announce", "event_nearby", "public_post", "ai_tip"),
      "timestamp" (ISO 8601 string, e.g., "${DateTime.now().toIso8601String()}", recent),
      "isPublic" (boolean, always true for newsfeed),
      "content" (string, main text, engaging and positive).

      Optional fields based on type:
      "avatarUrl" (dummy URL like "https://picsum.photos/100?random=${_uuid.v4()}"),
      "username" (string, e.g., "Alex_Match"),
      "location" (string, e.g., "Salt Lake City, UT").

      For "date_success" type: include "partnerName" (string, e.g., "Sophia"). Content should be a positive reflection on a date.
      For "match_announce" type: include "matchUsername" (string, e.g., "ChrisDater"). Content should celebrate a new match.
      For "event_nearby" type: include "eventName" (string), "eventDate" (ISO 8601 string, future date), "eventLocation" (string, e.g., "Downtown Cafe"). These should be plausible events and locations somewhat within a $userRadius mile radius of $userLocation.
      For "public_post" type: content should be a short, positive "tweet" about dating or social interaction, e.g., "Just had an amazing conversation about tree hugging! #BlindAIDating #DeepConnections".
      For "ai_tip" type: content should be a social engagement tip for BlindAIDating, following the "childlike wonder" theme (e.g., "Ask 'Why?' twice to truly understand someone's passion.").

      Ensure content is diverse and reflects different aspects of dating and social interaction.
      Make sure locations for 'date_success' and 'match_announce' feel natural for dating app users.
      Provide the output as a JSON array of these objects.
    ''';

    try {
      final String rawResponse = await _callEdgeFunction(promptText: prompt);
      final List<dynamic> jsonList = _parseAIJsonResponse(rawResponse);
      return jsonList.map((json) => NewsfeedItem.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error generating newsfeed items: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<UserProfile>> generateDummyUserProfiles(int count) async {
    final String currentIsoTime = DateTime.now().toIso8601String();

    final String prompt = '''
      Generate $count diverse, realistic dummy user profiles for a dating app called BlindAIDating.
      Each profile should be a JSON object with fields exactly matching a Supabase 'profiles' table row structure for Dart parsing, ensuring all fields expected by UserProfile.fromJson are present, with plausible dummy data.
      Include:
      "id" (unique UUID string, e.g., "${_uuid.v4()}"),
      "email" (string, valid dummy email, e.g., "user_${_uuid.v4().substring(0,4)}@example.com"),
      "full_name" (string, e.g., "Alice Johnson"),
      "display_name" (string, e.g., "CuriousAlice"),
      "profile_picture_url" (dummy URL like "https://picsum.photos/200?random=${_uuid.v4()}"), // Match the property name in UserProfile
      "bio" (string, 2-3 sentences, positive, engaging, reflects personality),
      "looking_for" (string, e.g., "Long-term relationship", "Friendship", "Casual dating", "Something open"),
      "profile_complete" (boolean, always true for these dummy profiles),
      "gender" (string, e.g., "Female", "Male", "Non-binary", "Prefer not to say"),
      "date_of_birth" (ISO 8601 string, e.g., "1990-05-15"),
      "phone_number" (string, dummy phone number, e.g., "+1555${_uuid.v4().substring(0,7).replaceAll('-', '')}"),
      "address_zip" (string, dummy 5-digit zip code, e.g., "84101"),
      "interests" (array of strings, 3-5 diverse hobbies/interests, e.g., ["hiking", "board games", "cooking", "jazz music"]),
      "sexual_orientation" (string, e.g., "Straight", "Gay", "Bisexual", "Pansexual", "Demisexual"),
      "height" (double, random height in cm, e.g., 170.5),
      "agreed_to_terms" (boolean, always true),
      "agreed_to_community_guidelines" (boolean, always true),
      "created_at" (ISO 8601 string, recent timestamp, e.g., "$currentIsoTime"),
      "last_updated" (ISO 8601 string, recent timestamp, e.g., "$currentIsoTime").

      Ensure diversity in all fields, especially 'looking_for' and 'interests'.
      Provide the output as a JSON array of these objects.
    ''';

    try {
      final String rawResponse = await _callEdgeFunction(promptText: prompt);
      final List<dynamic> jsonList = _parseAIJsonResponse(rawResponse);
      return jsonList.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error generating dummy user profiles: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<AIEngagementPrompt>> generateAIEngagementPrompts(int count) async {
    final String prompt = '''
      Generate $count AI-driven social engagement tips for a dating app called BlindAIDating.
      Each tip should be a JSON object with 'id' (unique string, e.g., "tip_${_uuid.v4()}"), and 'tip' (string, a short, actionable paragraph).
      Focus on encouraging "childlike wonder," genuine curiosity, and effective questioning techniques in conversation and interaction.
      Examples:
      - "Try asking 'Why?' twice after someone shares a passion – it helps you explore their deeper motivations and interests!"
      - "Discover common ground by asking about their happiest childhood memory related to a topic they enjoy."
      - "If they mention a hobby, ask 'What got you started in that?' to explore their unique journey and passion."
      - "Challenge yourself to ask open-ended questions that require more than a 'yes' or 'no' answer."
      - "Practice active listening by summarizing what you heard and asking 'Did I understand that correctly?'"
      Provide the output as a JSON array of these objects.
    ''';

    try {
      final String rawResponse = await _callEdgeFunction(promptText: prompt);
      final List<dynamic> jsonList = _parseAIJsonResponse(rawResponse);
      return jsonList.map((json) => AIEngagementPrompt.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error generating AI engagement prompts: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  // Placeholder for AI-driven match generation (more complex, involves user profiles)
  Future<List<Map<String, dynamic>>> generateDummyMatches(int count, List<UserProfile> existingProfiles) async {
    if (existingProfiles.length < 2) {
      debugPrint('Need at least 2 profiles to generate matches for dummy matches.');
      return [];
    }
    // Convert a sample of existing profiles to a string for the prompt
    // Ensure we only pass relevant, non-sensitive data to the AI prompt
    final String profileContext = existingProfiles.take(5).map((p) => 
      '{ "id": "${p.userId}", "display_name": "${p.displayName ?? p.fullName ?? 'User'}", "looking_for": "${p.lookingFor ?? 'Not set'}", "interests": ${jsonEncode(p.interests ?? [])} }'
    ).join(',\n');

    final String prompt = '''
      Given these existing user profiles from BlindAIDating for context (do not use their IDs directly for new match IDs):
      [
        $profileContext
      ]

      Generate $count dummy match suggestions. Each suggestion should be a JSON object with:
      "matchId" (unique string, e.g., "match_${_uuid.v4()}"),
      "user1Id" (string, one of the user IDs from the context),
      "user2Id" (string, another user ID from the context, different from user1Id),
      "matchDate" (ISO 8601 string, recent),
      "compatibilityScore" (integer, 60-99),
      "reason" (string, 1-2 sentences explaining the compatibility based on their interests and 'looking_for' intentions.).

      Ensure matches are plausible based on their 'looking_for' intentions and 'interests'.
      Do not match a user with themselves.
      Provide the output as a JSON array of these objects.
    ''';

    try {
      final String rawResponse = await _callEdgeFunction(promptText: prompt);
      final List<dynamic> jsonList = _parseAIJsonResponse(rawResponse);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      debugPrint('Error generating dummy matches: $e');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }
}