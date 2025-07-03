// lib/services/profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart'; // Ensure UserProfile is imported
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:cross_file/cross_file.dart'; // FIXED: Import XFile

class ProfileService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Fetches a user profile by their UUID (which is the 'id' in the profiles table)
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId) // Corrected: Query by 'id' column
          .single(); // Expecting a single row for a user's profile

      if (response.isNotEmpty) {
        return UserProfile.fromJson(response);
      }
      return null; // Profile not found
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error fetching user profile for $userId: ${e.message}');
      throw e; // Re-throw to be caught by calling widget/service
    } catch (e) {
      debugPrint('General Error fetching user profile for $userId: $e');
      rethrow; // Re-throw any other exceptions
    }
  }

  // Creates or updates a user profile
  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    try {
      // Upsert: if 'id' exists, update; otherwise, insert
      // FIXED: Removed .execute() as it's not needed with newer Supabase Flutter versions
      await _supabaseClient
          .from('profiles')
          .upsert(profile.toJson())
          .eq('id', profile.userId); // Ensure upsert uses 'id' to match existing row
      debugPrint('Profile for ${profile.userId} upserted successfully.');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Postgrest Error creating/updating profile for ${profile.userId}: ${e.message}');
      throw e;
    } catch (e) {
      debugPrint('General Error creating/updating profile for ${profile.userId}: $e');
      rethrow;
    }
  }

  // Uploads an analysis photo to Supabase Storage and returns the public URL
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      // Define the path in storage
      final String path = 'analysis_photos/$userId/${imageFile.name}';

      // Upload the file
      final String publicUrl = await _supabaseClient.storage
          .from('avatars') // Assuming 'avatars' bucket is used for profile pictures
          .upload(path, await imageFile.readAsBytes(),
              fileOptions: const FileOptions(upsert: true));

      // Get the public URL for the uploaded file
      final String signedUrl = _supabaseClient.storage.from('avatars').getPublicUrl(path);
      return signedUrl; // Return the public URL
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error uploading photo: ${e.message}');
      throw e;
    } catch (e) {
      debugPrint('General Error uploading photo: $e');
      rethrow;
    }
  }
}