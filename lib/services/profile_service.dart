// lib/services/profile_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:uuid/uuid.dart';

import 'package:bliindaidating/platform_utils/platform_helper_factory.dart';
import 'package:bliindaidating/platform_utils/abstract_platform_helpers.dart';
// NEW: Import dummy data
import 'package:bliindaidating/data/dummy_data.dart';

class ProfileService with ChangeNotifier {
  final SupabaseClient _supabase;
  UserProfile? _userProfile;
  bool _isProfileLoaded = false;
  bool _isLoading = false;

  final AbstractPlatformHelpers _platformHelpers = getPlatformHelpers();

  ProfileService(this._supabase);

  UserProfile? get userProfile => _userProfile;
  bool get isProfileLoaded => _isProfileLoaded;
  bool get isLoading => _isLoading;

  // NEW: A simple flag to toggle between live data and dummy data
  // This is set to true in debug mode and false in release mode
  static const bool useDummyData = kDebugMode;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setProfileLoaded(bool value) {
    _isProfileLoaded = value;
    notifyListeners();
  }

  void updateProfileLocally(UserProfile newProfile) {
    if (_userProfile?.id != newProfile.id || _userProfile?.toJson().toString() != newProfile.toJson().toString()) {
      _userProfile = newProfile;
      notifyListeners();
      debugPrint('ProfileService: Profile updated locally.');
    }
  }

  void clearProfile() {
    _userProfile = null;
    _isProfileLoaded = false;
    notifyListeners();
    debugPrint('ProfileService: Profile cleared.');
  }

  Future<void> initializeProfile() async {
    if (_isProfileLoaded || _isLoading) {
      debugPrint('ProfileService: initializeProfile skipped, profile already loaded or loading.');
      return;
    }

    _setLoading(true);

    if (useDummyData) {
      debugPrint('ProfileService: Using dummy data for profile.');
      _userProfile = dummyUserProfile;
      _setProfileLoaded(true);
      _setLoading(false);
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchUserProfile(id: user.id, isInitialization: true);
    } else {
      clearProfile();
      _setProfileLoaded(true);
      _setLoading(false);
    }
  }

  Future<UserProfile?> fetchUserProfile({required String id, bool isInitialization = false}) async {
    if (!isInitialization) {
      _setLoading(true);
    }
    debugPrint('ProfileService: Attempting to fetch user profile for ID: $id (isInitialization: $isInitialization)');
    try {
      final response = await _supabase.from('user_profiles').select().eq('id', id).single();
      _userProfile = UserProfile.fromJson(response);
      debugPrint('ProfileService: User profile fetched: ${_userProfile?.toJson()}');
      return _userProfile;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        debugPrint('ProfileService: Profile not found for ID $id. This is expected for new users.');
        _userProfile = UserProfile(
          id: id,
          email: _supabase.auth.currentUser?.email ?? 'N/A',
          createdAt: DateTime.now().toUtc(),
        );
        return _userProfile;
      } else {
        debugPrint('ProfileService: Postgrest error fetching profile: ${e.message}');
        _userProfile = null;
        return null;
      }
    } catch (e, stack) {
      debugPrint('ProfileService: Unexpected error fetching profile: $e\n$stack');
      _userProfile = null;
      return null;
    } finally {
      _setProfileLoaded(true);
      _setLoading(false);
    }
  }

  Future<void> updateProfile({required UserProfile profile}) async {
    _setLoading(true);
    try {
      if (useDummyData) {
        debugPrint('ProfileService: Simulating profile update with dummy data.');
        _userProfile = profile;
        notifyListeners();
        return;
      }
      final response = await _supabase.from('user_profiles').upsert(profile.toJson()).select().single();
      _userProfile = UserProfile.fromJson(response);
      notifyListeners();
      debugPrint('ProfileService: Profile updated: ${_userProfile?.toJson()}');
    } on PostgrestException catch (e) {
      debugPrint('ProfileService: Postgrest error updating profile: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('ProfileService: Unexpected error updating profile: $e\n$stack');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markPhase1Complete() async {
    if (_userProfile == null) return;
    final updatedProfile = _userProfile!.copyWith(isPhase1Complete: true);
    await updateProfile(profile: updatedProfile);
    debugPrint('ProfileService: Marked Phase 1 as complete.');
  }

  Future<void> markPhase2Complete() async {
    if (_userProfile == null) return;
    final updatedProfile = _userProfile!.copyWith(isPhase2Complete: true);
    await updateProfile(profile: updatedProfile);
    debugPrint('ProfileService: Marked Phase 2 as complete.');
  }

  // NEW: A public method to simulate Phase 2 completion, useful for testing
  void simulatePhase2Completion() {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(isPhase2Complete: true);
      notifyListeners();
      debugPrint('ProfileService: Dummy user profile updated to isPhase2Complete: true');
    }
  }

  Future<String?> uploadProfileAvatar(Uint8List fileBytes, String fileName) async {
    // This method needs to be modified to handle the useDummyData flag if needed
    // ... (Your existing implementation here)
    return null;
  }

  Future<Uint8List?> pickAndPrepareAvatar() async {
    // This method needs to be modified to handle the useDummyData flag if needed
    // ... (Your existing implementation here)
    return null;
  }

  Future<void> handleAvatarUpload() async {
    // This method needs to be modified to handle the useDummyData flag if needed
    // ... (Your existing implementation here)
  }

  Future<String?> uploadAnalysisPhoto(String userId, String imagePath) async {
    // This method needs to be modified to handle the useDummyData flag if needed
    // ... (Your existing implementation here)
    return null;
  }

  Future<void> insertProfile(UserProfile profile) async {
    // This method needs to be modified to handle the useDummyData flag if needed
    // ... (Your existing implementation here)
  }

  Future<List<UserProfile>> fetchAllUserProfiles() async {
    if (useDummyData) {
      return dummyDiscoveryProfiles; // NEW: Return dummy discovery profiles
    }
    // ... (Your existing implementation here)
    return [];
  }

  Future<String> generateDummyUsers(int count) async {
    if (useDummyData) {
      debugPrint('ProfileService: Cannot generate dummy users while in dummy data mode.');
      return 'Cannot generate dummy users while in dummy data mode.';
    }
    // ... (Your existing implementation here)
    return '';
  }
}