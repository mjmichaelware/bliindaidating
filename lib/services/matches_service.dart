// lib/services/matches_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/user_profile.dart'; // Assuming UserProfile model exists

/// A service to manage user matches.
class MatchesService extends ChangeNotifier {
  List<UserProfile> _matches = [];
  List<UserProfile> get matches => _matches;

  MatchesService() {
    _fetchMatches(); // Fetch matches on initialization
  }

  Future<void> _fetchMatches() async {
    debugPrint('MatchesService: Attempting to fetch matches...');
    // Placeholder for actual data fetching logic
    // In a real app, this would fetch from Supabase or your backend API
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    _matches = [
      // Example dummy matches, now providing required 'createdAt'
      UserProfile(
        userId: 'match_user_1',
        email: 'match1@example.com',
        displayName: 'Astro Explorer',
        bio: 'Loves stargazing and deep conversations about the universe.',
        profilePictureUrl: 'https://placehold.co/150x150/FF6347/FFFFFF?text=M1',
        isPhase1Complete: true,
        isPhase2Complete: true,
        astrologicalSign: 'Leo',
        personalityTraits: ['Curious', 'Adventurous'],
        hobbiesAndInterests: ['Astronomy', 'Hiking', 'Sci-Fi Movies'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)), // Provided
        updatedAt: DateTime.now().subtract(const Duration(days: 5)), // Provided
      ),
      UserProfile(
        userId: 'match_user_2',
        email: 'match2@example.com',
        displayName: 'Cosmic Chef',
        bio: 'Passionate about culinary arts and exploring new galaxies (of flavor).',
        profilePictureUrl: 'https://placehold.co/150x150/4682B4/FFFFFF?text=M2',
        isPhase1Complete: true,
        isPhase2Complete: true,
        astrologicalSign: 'Taurus',
        personalityTraits: ['Creative', 'Grounded'],
        hobbiesAndInterests: ['Cooking', 'Gardening', 'Travel'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)), // Provided
        updatedAt: DateTime.now().subtract(const Duration(days: 10)), // Provided
      ),
    ];
    debugPrint('MatchesService: Fetched ${_matches.length} matches.');
    notifyListeners();
  }

  // You can add methods here for accepting/rejecting matches, etc.
  Future<void> refreshMatches() async {
    await _fetchMatches();
  }
}