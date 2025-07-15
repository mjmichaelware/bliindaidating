// lib/services/profile_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/user_profile.dart'; // Ensure this path is correct
import 'package:image_picker/image_picker.dart'; // For XFile
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // For jsonDecode
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for base URL

// Conditional import for File:
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:io' as io; // Explicitly import dart:io as 'io'

class ProfileService extends ChangeNotifier {
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  // Added: Flag to indicate initial profile load status
  bool _isProfileLoaded = false;
  bool get isProfileLoaded => _isProfileLoaded;

  ProfileService(); // Parameterless constructor

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
    debugPrint('ProfileService: User profile updated to: ${profile?.userId}');
  }

  void clearProfile() {
    _userProfile = null;
    _isProfileLoaded = true; // Mark as loaded even if cleared
    notifyListeners();
    debugPrint('ProfileService: User profile cleared.');
  }

  /// Initializes the profile service by attempting to fetch the current user's profile.
  /// This should be called once on app startup.
  Future<void> initializeProfile() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      await fetchUserProfile(currentUser.id);
    } else {
      _userProfile = null; // Ensure no stale profile if no user logged in
    }
    _isProfileLoaded = true; // Mark as loaded after initial check
    notifyListeners(); // Notify listeners that initial load is complete
    debugPrint('ProfileService: Initial profile load complete. User: ${currentUser?.id}, Profile exists: ${_userProfile != null}');
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
          .from('profile_pictures') // Ensure this bucket exists in Supabase Storage
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
          .eq('id', profile.userId); // Corrected: Use 'id' matching UserProfile.userId

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
          .eq('id', userId) // Corrected: Use 'id' matching UserProfile.userId
          .single();

      if (response != null) {
        final profile = UserProfile.fromJson(response);
        setUserProfile(profile);
        return profile;
      }
      return null;
    } on PostgrestException catch (e) {
      // Supabase's PostgREST returns 'PGRST116' (or a message indicating '0 rows')
      // when .single() finds no matching record. This is expected for new users.
      if (e.code == 'PGRST116' || e.message.contains('0 rows')) {
        debugPrint('Profile not found for user $userId (likely first login or not yet created).');
        setUserProfile(null); // Clear local profile if not found and notify
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

  /// NEW: Fetches a list of all user profiles from the backend.
  /// This is used for displaying profiles in Discovery/Matches.
  Future<List<UserProfile>> fetchAllUserProfiles({int limit = 10, int offset = 0}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/user-profiles/?limit=$limit&offset=$offset');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['profiles'] is List) {
          return List<UserProfile>.from(
            (data['profiles'] as List).map((json) => UserProfile.fromJson(json))
          );
        }
        debugPrint('Backend returned unexpected format for /user-profiles: ${response.body}');
        return [];
      } else {
        debugPrint('Failed to fetch all user profiles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching all user profiles: $e');
      return [];
    }
  }

  /// NEW: Triggers the backend to generate dummy users in Supabase.
  Future<String?> generateDummyUsers(int count) async {
    final url = Uri.parse('${AppConstants.baseUrl}/generate-dummy-users/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'count': count});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message']; // Returns the success message
      } else {
        debugPrint('Failed to generate dummy users: ${response.statusCode} - ${response.body}');
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['error'] ?? 'Unknown error generating dummy users';
      }
    } catch (e) {
      debugPrint('Error generating dummy users: $e');
      return 'Network error: $e';
    }
  }
}