// lib/services/profile_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // For XFile type
import 'package:bliindaidating/models/user_profile.dart'; // Ensure this model is correctly defined

/// A service class to handle user profile data operations,
/// including fetching, updating, creating, and providing real-time updates.
class ProfileService extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  ProfileService() {
    // No initial fetch here; it's handled by main.dart's redirect or MainDashboardScreen.
    // This constructor primarily sets up the service for use with Provider.
  }

  /// Fetches the user profile from Supabase.
  Future<UserProfile?> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading has started
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        debugPrint('ProfileService: Fetched profile for user ID: $userId');
      } else {
        _userProfile = null;
        debugPrint('ProfileService: No profile found for user ID: $userId');
      }
      return _userProfile;
    } on PostgrestException catch (e) {
      debugPrint('ProfileService: Error fetching profile for $userId: ${e.message}');
      _userProfile = null; // Clear profile on error
      rethrow; // Re-throw to be handled by the caller
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }

  /// Uploads an analysis photo to Supabase storage.
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String path = 'public/analysis_photos/$userId/${imageFile.name}';
      final Uint8List fileBytes = await imageFile.readAsBytes();

      await _supabaseClient.storage.from('profile_photos').uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(
              upsert: true, // Overwrite if file exists
              contentType: 'image/jpeg', // Assuming JPEG, adjust as needed
            ),
          );

      final String publicUrl = _supabaseClient.storage.from('profile_photos').getPublicUrl(path);
      debugPrint('ProfileService: Uploaded analysis photo for $userId to: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('ProfileService: Error uploading analysis photo for $userId: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new user profile or updates an existing one in Supabase.
  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Supabase's upsert functionality is useful here.
      // It will insert if the ID doesn't exist, or update if it does.
      final response = await _supabaseClient
          .from('profiles')
          .upsert(profile.toJson()) // Convert UserProfile object to JSON map
          .eq('id', profile.userId) // Condition for update
          .select(); // Select the updated/inserted row to get fresh data

      if (response != null && response.isNotEmpty) {
        _userProfile = UserProfile.fromJson(response.first); // Update local state with fresh data
        debugPrint('ProfileService: Profile created/updated for user ID: ${profile.userId}');
      } else {
        debugPrint('ProfileService: Profile upsert operation returned empty response for user ID: ${profile.userId}');
      }
    } on PostgrestException catch (e) {
      debugPrint('ProfileService: Error creating/updating profile for ${profile.userId}: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates specific fields of the user profile in Supabase.
  /// This is a more general update method, similar to the one already present.
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? displayName,
    String? profilePictureUrl,
    bool? isPhase1Complete,
    bool? isPhase2Complete,
    // Add other fields you might want to update here as well
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> updates = {};
      if (fullName != null) updates['full_name'] = fullName;
      if (displayName != null) updates['display_name'] = displayName;
      if (profilePictureUrl != null) updates['profile_picture_url'] = profilePictureUrl;
      if (isPhase1Complete != null) updates['is_phase1_complete'] = isPhase1Complete;
      if (isPhase2Complete != null) updates['is_phase2_complete'] = isPhase2Complete;

      if (updates.isNotEmpty) {
        await _supabaseClient
            .from('profiles')
            .update(updates)
            .eq('id', userId);

        // Update local state after successful update
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            fullName: fullName,
            displayName: displayName,
            profilePictureUrl: profilePictureUrl,
            isPhase1Complete: isPhase1Complete,
            isPhase2Complete: isPhase2Complete,
          );
        }
        debugPrint('ProfileService: Profile updated for user ID: $userId');
      }
    } on PostgrestException catch (e) {
      debugPrint('ProfileService: Error updating profile for $userId: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}