// lib/services/profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/utils/supabase_config.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Import UserProfile model
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint


class ProfileService {
  final SupabaseClient _client = SupabaseConfig.client;

  // --- Database Operations ---

  /// Fetches a user's profile from the 'profiles' table.
  /// Returns null if profile not found or user is not authenticated.
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final Map<String, dynamic> response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .limit(1)
          .single(); // Expecting a single row or null

      if (response != null) {
        return UserProfile.fromMap(response);
      }
      return null; // Profile not found
    } on PostgrestException catch (e) {
      debugPrint('Supabase Database Error (getProfile): ${e.message}');
      throw Exception('Failed to fetch profile: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error (getProfile): $e');
      rethrow;
    }
  }

  /// Creates or updates a user's profile in the 'profiles' table.
  /// Uses upsert, so it inserts if ID doesn't exist, updates if it does.
  Future<void> createOrUpdateProfile(UserProfile profile) async {
    try {
      final Map<String, dynamic> data = profile.toMap();
      data['id'] = profile.uid; // Explicitly set 'id' in map

      await _client
          .from('profiles')
          .upsert(data, onConflict: 'id'); // onConflict takes a String
      debugPrint('Profile for ${profile.uid} upserted successfully.');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Database Error (createOrUpdateProfile): ${e.message}');
      throw Exception('Failed to save profile: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error (createOrUpdateProfile): $e');
      rethrow;
    }
  }

  // --- Storage Operations (for Analysis Photos) ---

  /// Uploads an analysis photo to Supabase Storage and returns its path.
  /// The bucket 'analysis-photos' MUST be private.
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    final String fileExtension = imageFile.name.split('.').last;
    final String path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    try {
      final String uploadedPath = await _client.storage
          .from('analysis-photos')
          .upload(path, await imageFile.readAsBytes(),
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ));

      debugPrint('Analysis photo uploaded to path: $uploadedPath');
      return uploadedPath;
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error (uploadAnalysisPhoto): ${e.message}');
      throw Exception('Failed to upload analysis photo: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error (uploadAnalysisPhoto): $e');
      rethrow;
    }
  }

  /// Generates a temporary signed URL for an authenticated user to view their OWN private analysis photo.
  Future<String?> getAnalysisPhotoSignedUrl(String path) async {
    try {
      final String signedUrl = await _client.storage
          .from('analysis-photos')
          .createSignedUrl(path, 60);

      debugPrint('Generated signed URL for $path');
      return signedUrl;
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error (getAnalysisPhotoSignedUrl): ${e.message}');
      throw Exception('Failed to get signed URL: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected Error (getAnalysisPhotoSignedUrl): $e');
      return null;
    }
  }

  /// Deletes an analysis photo from Supabase Storage.
  Future<void> deleteAnalysisPhoto(String pathInBucket) async {
    try {
      await _client.storage.from('analysis-photos').remove([pathInBucket]);

      debugPrint('Analysis photo deleted successfully: $pathInBucket');
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error (deleteAnalysisPhoto): ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Unexpected Error (deleteAnalysisPhoto): $e');
    }
  }
}