// lib/services/discovery_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint, and kIsWeb
import 'package:bliindaidating/models/user_profile.dart'; // Assuming UserProfile model exists
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase client

/// A service to manage discovering new user profiles.
/// This service fetches profiles for the DiscoverPeopleScreen.
class DiscoveryService extends ChangeNotifier {
  List<UserProfile> _discoveredProfiles = [];
  List<UserProfile> get discoveredProfiles => _discoveredProfiles;

  DiscoveryService() {
    _fetchDiscoveredProfiles(); // Fetch profiles on initialization
  }

  Future<void> _fetchDiscoveredProfiles() async {
    debugPrint('DiscoveryService: Attempting to fetch discovered profiles...');
    try {
      // This is a placeholder. In a real app, you'd fetch from your backend
      // or directly from Supabase with appropriate Row Level Security (RLS).
      // Avoid using dart:io.Platform directly in shared logic for web compatibility.

      // Example of fetching profiles from Supabase (ensure RLS allows this for discovery)
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .limit(10); // Fetch a small number for discovery

      if (response.isNotEmpty) {
        _discoveredProfiles = List<UserProfile>.from(
          response.map((json) => UserProfile.fromJson(json))
        );
        debugPrint('DiscoveryService: Fetched ${_discoveredProfiles.length} profiles from Supabase.');
      } else {
        _discoveredProfiles = [];
        debugPrint('DiscoveryService: No profiles found for discovery.');
      }

    } catch (e) {
      debugPrint('DiscoveryService: Error fetching discovered profiles: $e');
      // You might want to handle specific errors, e.g., network issues
    }
    notifyListeners();
  }

  // You can add methods here for swiping, filtering, etc.
  Future<void> refreshDiscoveredProfiles() async {
    await _fetchDiscoveredProfiles();
  }
}