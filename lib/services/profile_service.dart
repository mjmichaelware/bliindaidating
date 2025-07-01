// lib/services/profile_service.dart
import 'dart:typed_data'; // For Uint8List for web uploads
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // Added debugPrint import
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';

/// A service class for managing user profiles in Supabase.
/// This includes fetching, creating/updating profiles, and handling photo uploads.
class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _profileTableName = 'profiles'; // Replace with your actual profiles table name
  final String _bucketName = 'analysis_photos'; // Supabase storage bucket name

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
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(_profileTableName)
          .select()
          .eq('id', userId)
          .single(); // Use .single() to expect at most one row

      if (response.isNotEmpty) {
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error getting user profile for $userId: $e');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  /// Creates a new user profile or updates an existing one.
  Future<void> createOrUpdateProfile({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required String gender,
    required String bio,
    String? profilePictureUrl,
    bool isProfileComplete = true, // Default to true upon initial setup
    List<String>? interests,
    String? lookingFor,
  }) async {
    try {
      final Map<String, dynamic> profileData = {
        'id': userId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'bio': bio,
        'profile_picture_url': profilePictureUrl,
        'is_profile_complete': isProfileComplete,
        'interests': interests ?? [], // Store as JSONB array in Supabase
        'looking_for': lookingFor,
        'updated_at': DateTime.now().toIso8601String(), // Ensure this column exists in your DB
      };

      await _supabase.from(_profileTableName).upsert(profileData, onConflict: 'id');
      debugPrint('Profile for $userId upserted successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error upserting profile for $userId: $e');
      debugPrint(stackTrace.toString());
      rethrow; // Re-throw to allow calling screen to handle
    }
  }

  /// Uploads an analysis photo to Supabase storage.
  /// Handles both web (Uint8List) and mobile (File) inputs.
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final String path = '$userId/profile_pictures/${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        // For web, use Uint8List bytes from XFile
        final Uint8List bytes = await imageFile.readAsBytes();
        final response = await _supabase.storage.from(_bucketName).uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );
        return response; // response contains the path if successful
      } else {
        // For mobile, use File
        final response = await _supabase.storage.from(_bucketName).upload(
              path,
              imageFile.path,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );
        return response; // response contains the path if successful
      }
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error uploading photo: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('General Error uploading photo: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Retrieves a signed URL for a given storage path.
  Future<String?> getAnalysisPhotoSignedUrl(String storagePath) async {
    try {
      final String publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
      // For publicly readable buckets, getPublicUrl is sufficient.
      // If your bucket is private, you would use createSignedUrl:
      // final String signedUrl = await _supabase.storage.from(_bucketName).createSignedUrl(storagePath, 60 * 60 * 24 * 7); // 7 days
      return publicUrl;
    } catch (e, stackTrace) {
      debugPrint('Error getting signed URL for $storagePath: $e');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  /// Saves a user's interests. Assumes 'interests' is an array column in your profiles table.
  Future<void> saveUserInterests(String userId, List<String> interests) async {
    try {
      await _supabase.from(_profileTableName).update({
        'interests': interests,
      }).eq('id', userId);
      debugPrint('User interests for $userId saved successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error saving user interests for $userId: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Saves a user's intentions. Assumes 'looking_for' is a column in your profiles table.
  Future<void> saveUserIntentions(String userId, List<String> intentions) async {
    try {
      // Assuming 'looking_for' is a single string. If it's multiple, adjust schema and data type.
      // For now, take the first intention or null if list is empty.
      final String? lookingFor = intentions.isNotEmpty ? intentions.first : null;

      await _supabase.from(_profileTableName).update({
        'looking_for': lookingFor,
      }).eq('id', userId);
      debugPrint('User intentions for $userId saved successfully.');
    } catch (e, stackTrace) {
      debugPrint('Error saving user intentions for $userId: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}