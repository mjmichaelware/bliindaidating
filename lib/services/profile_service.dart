// lib/services/profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart'; // Ensure XFile is imported for uploadAnalysisPhoto

class ProfileService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select() // Selects all columns implicitly
          .eq('id', userId)
          .single(); // Expecting a single row for a user's profile

      if (response.isNotEmpty) {
        return UserProfile.fromJson(response);
      }
      return null; // Profile not found
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error fetching user profile for $userId: ${e.message}');
      throw e;
    } catch (e) {
      debugPrint('General Error fetching user profile for $userId: $e');
      rethrow;
    }
  }

  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    try {
      await _supabaseClient
          .from('profiles')
          .upsert(profile.toJson())
          .eq('id', profile.userId);
      debugPrint('Profile for ${profile.userId} upserted successfully.');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error creating/updating profile for ${profile.userId}: ${e.message}');
      throw e;
    } catch (e) {
      debugPrint('General Error creating/updating profile for ${profile.userId}: $e');
      rethrow;
    }
  }

  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final String path = 'analysis_photos/$userId/${imageFile.name}';

      // Ensure 'avatars' bucket exists in your Supabase storage
      final String publicUrl = await _supabaseClient.storage
          .from('avatars')
          .upload(path, await imageFile.readAsBytes(),
              fileOptions: const FileOptions(upsert: true));

      final String signedUrl = _supabaseClient.storage.from('avatars').getPublicUrl(path);
      return signedUrl;
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error uploading photo: ${e.message}');
      throw e;
    } catch (e) {
      debugPrint('General Error uploading photo: $e');
      rethrow;
    }
  }
}