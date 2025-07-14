// lib/services/profile_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/user_profile.dart'; // Ensure this path is correct
import 'package:image_picker/image_picker.dart'; // For XFile
import 'dart:typed_data'; // For Uint8List

// Conditional import for File:
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:io' as io; // Explicitly import dart:io as 'io'

class ProfileService extends ChangeNotifier {
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  ProfileService(); // Parameterless constructor

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
    debugPrint('ProfileService: User profile updated to: ${profile?.userId}');
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
    debugPrint('ProfileService: User profile cleared.');
  }

  Future<String> uploadAnalysisPhoto(String userId, dynamic file) async {
    try {
      final String path = 'analysis_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Uint8List bytes;
      if (file is XFile) {
        bytes = await file.readAsBytes();
      } else if (file is io.File) { // Explicitly check for dart:io.File
        bytes = await file.readAsBytes();
      } else if (file is html.File) { // Explicitly check for dart:html.File
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first; // Wait for the file to be read
        if (reader.result is Uint8List) {
          bytes = reader.result as Uint8List;
        } else {
          throw Exception("Failed to read HTML file as Uint8List.");
        }
      } else if (file is Uint8List) {
        bytes = file;
      } else {
        throw Exception("Unsupported file type for uploadAnalysisPhoto");
      }

      await Supabase.instance.client.storage
          .from('profile_pictures')
          .uploadBinary(path, bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl = Supabase.instance.client.storage.from('profile_pictures').getPublicUrl(path);

      debugPrint('Analysis photo uploaded to: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('Storage Error uploading analysis photo: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Error uploading analysis photo: $e');
      rethrow;
    }
  }

  Future<void> insertProfile(UserProfile profile) async {
    try {
      await Supabase.instance.client
          .from('user_profiles')
          .insert(profile.toJson());

      setUserProfile(profile);
      debugPrint('Profile inserted successfully for user: ${profile.userId}');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Error inserting profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Error inserting profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await Supabase.instance.client
          .from('user_profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId);

      setUserProfile(profile);
      debugPrint('Profile updated successfully for user: ${profile.userId}');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Error updating profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Error updating profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      if (response != null) {
        final profile = UserProfile.fromJson(response);
        setUserProfile(profile);
        return profile;
      }
      return null;
    } on PostgrestException catch (e) {
      if (e.code == '22P02') {
        debugPrint('Profile not found for user $userId (likely first login).');
        setUserProfile(null);
        return null;
      }
      debugPrint('Supabase Error fetching profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> loadUserProfile(String userId) async {
    await fetchUserProfile(userId);
  }
}