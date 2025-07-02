// lib/services/profile_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';

/// A service class for managing user profiles in Supabase.
/// This includes fetching, creating/updating profiles, and handling photo uploads.
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _profileTableName = 'profiles';
  final String _bucketName = 'profile_images'; // Ensure this bucket exists

  // Private constructor for singleton pattern
  ProfileService._privateConstructor();

  // Singleton instance
  static final ProfileService _instance = ProfileService._privateConstructor();

  // Factory constructor to return the same instance
  factory ProfileService() {
    return _instance;
  }

  /// Fetches a user's profile by their user ID.
  /// Returns null if the profile does not exist.
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_profileTableName)
          .select()
          .eq('user_id', userId)
          .single();

      return UserProfile.fromJson(response);

    } on PostgrestException catch (e, stackTrace) { // Added stackTrace here
      if (e.code == 'PGRST116') {
        debugPrint('No existing profile found for user $userId (PGRST116).');
        return null;
      }
      debugPrint('Error fetching user profile for $userId: ${e.message}');
      debugPrint(stackTrace.toString()); // Use the stackTrace from the catch block
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('General Error fetching user profile for $userId: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Creates a new user profile or updates an existing one using a UserProfile object.
  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    try {
      await _supabase.from(_profileTableName).upsert(profile.toJson(), onConflict: 'user_id');
      debugPrint('Profile for ${profile.userId} upserted successfully.');
    } on PostgrestException catch (e, stackTrace) { // Added stackTrace here
      debugPrint('Supabase Postgrest Error upserting profile for ${profile.userId}: ${e.message}');
      debugPrint(stackTrace.toString()); // Use the stackTrace from the catch block
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('General Error upserting profile for ${profile.userId}: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Uploads an analysis photo to Supabase storage.
  /// Returns the full public URL of the uploaded file.
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final String fileName = 'analysis_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.png';

      String uploadedPath;
      if (kIsWeb) {
        final Uint8List bytes = await imageFile.readAsBytes();
        uploadedPath = await _supabase.storage.from(_bucketName).uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
            );
      } else {
        uploadedPath = await _supabase.storage.from(_bucketName).upload(
              fileName,
              imageFile.path,
              fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
            );
      }
      return _supabase.storage.from(_bucketName).getPublicUrl(uploadedPath);
    } on StorageException catch (e, stackTrace) { // Added stackTrace here
      debugPrint('Supabase Storage Error uploading photo: ${e.message}');
      debugPrint(stackTrace.toString()); // Use the stackTrace from the catch block
      return null;
    } catch (e, stackTrace) {
      debugPrint('General Error uploading photo: $e');
      debugPrint(stackTrace.toString());
      return null;
    }
  }
}