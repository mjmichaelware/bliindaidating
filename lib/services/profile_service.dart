// lib/services/profile_service.dart
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Keep this, as it's cross-platform for picking
import 'dart:typed_data';
import 'dart:async'; // For Completer
import 'package:flutter/services.dart'; // For ByteData
import 'package:bliindaidating/models/user_profile.dart';
import 'package:uuid/uuid.dart';

// REMOVE these specific imports, as we now use a unified factory
// import 'package:bliindaidating/platform_utils/platform_io_helpers.dart';
// import 'package:bliindaidating/platform_utils/platform_html_helpers.dart';

// NEW: Import our new unified platform helper factory and the abstract interface
import 'package:bliindaidating/platform_utils/platform_helper_factory.dart';
import 'package:bliindaidating/platform_utils/abstract_platform_helpers.dart';

class ProfileService with ChangeNotifier {
  final SupabaseClient _supabase;
  UserProfile? _userProfile;
  bool _isProfileLoaded = false;
  bool _isLoading = false;

  // NEW: Instantiate the single abstract platform helper from the factory
  final AbstractPlatformHelpers _platformHelpers = getPlatformHelpers();

  ProfileService(this._supabase);

  UserProfile? get userProfile => _userProfile;
  bool get isProfileLoaded => _isProfileLoaded;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setProfileLoaded(bool value) {
    _isProfileLoaded = value;
    notifyListeners();
  }

  void clearProfile() {
    _userProfile = null;
    _isProfileLoaded = false;
    notifyListeners();
    debugPrint('ProfileService: Profile cleared.');
  }

  Future<void> initializeProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchUserProfile(id: user.id);
    } else {
      clearProfile();
      _setProfileLoaded(true);
    }
  }

  Future<UserProfile?> fetchUserProfile({required String id}) async {
    _setLoading(true);
    debugPrint('ProfileService: Attempting to fetch user profile for ID: $id');
    try {
      final response = await _supabase.from('profiles').select().eq('id', id).single();
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
      final response = await _supabase.from('profiles').upsert(profile.toJson()).select().single();
      _userProfile = UserProfile.fromJson(response);
      debugPrint('ProfileService: Profile updated: ${_userProfile?.toJson()}');
      notifyListeners();
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

  Future<String?> uploadProfileAvatar(Uint8List fileBytes, String fileName) async {
    try {
      final String path = _supabase.auth.currentUser!.id;
      final String filePath = '$path/$fileName';

      final String publicUrl = await _supabase.storage.from('avatars').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      debugPrint('ProfileService: Avatar uploaded to: $publicUrl');

      await _supabase.from('profiles').update({
        'profile_picture_url': publicUrl,
      }).eq('id', _supabase.auth.currentUser!.id);

      _userProfile = _userProfile?.copyWith(profilePictureUrl: publicUrl);
      notifyListeners();
      return publicUrl;
    } catch (e, stack) {
      debugPrint('ProfileService: Error uploading avatar: $e\n$stack');
      rethrow;
    }
  }

  // This method will pick an image and prepare it for upload
  // *** SIMPLIFIED: Now uses ImagePicker consistently across all platforms. ***
  Future<Uint8List?> pickAndPrepareAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        debugPrint('ProfileService: Image picked: ${image.path}');
        return await image.readAsBytes();
      } else {
        debugPrint('ProfileService: No image selected.');
        return null;
      }
    } catch (e, stack) {
      debugPrint('ProfileService: Error picking or preparing avatar: $e\n$stack');
      rethrow;
    }
  }

  Future<void> handleAvatarUpload() async {
    _setLoading(true);
    try {
      final Uint8List? imageBytes = await pickAndPrepareAvatar();
      if (imageBytes != null) {
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
        await uploadProfileAvatar(imageBytes, fileName);
        debugPrint('ProfileService: Avatar upload process completed successfully.');
      } else {
        debugPrint('ProfileService: No image bytes received for upload.');
      }
    } catch (e) {
      debugPrint('ProfileService: Failed to handle avatar upload process: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadAnalysisPhoto(String userId, String imagePath) async {
    _setLoading(true);
    try {
      Uint8List? fileBytes;
      String fileName = 'analysis_photo_${DateTime.now().millisecondsSinceEpoch}.png';

      // *** CORRECTED: Explicitly handle web case as `readFileAsBytes` isn't meant for web paths. ***
      if (kIsWeb) {
        debugPrint('ProfileService: uploadAnalysisPhoto: `imagePath` is not directly readable on web. '
                     'Consider refactoring to accept Uint8List directly or use a web-specific picker first.');
        throw UnsupportedError('uploadAnalysisPhoto with imagePath not directly supported for local file paths on web. '
                               'Provide Uint8List directly or use a web file picker first.');
      } else {
        // Use the unified `_platformHelpers` instance and its `readFileAsBytes` method for IO platforms.
        fileBytes = await _platformHelpers.readFileAsBytes(imagePath);
      }

      if (fileBytes == null) {
        debugPrint('ProfileService: No file bytes to upload for analysis photo.');
        return null;
      }

      final String path = userId;
      final String filePath = '$path/$fileName';

      final String publicUrl = await _supabase.storage.from('analysis_photos').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      debugPrint('ProfileService: Analysis photo uploaded to: $publicUrl');
      return publicUrl;
    } catch (e, stack) {
      debugPrint('ProfileService: Error uploading analysis photo: $e\n$stack');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> insertProfile(UserProfile profile) async {
    _setLoading(true);
    try {
      await _supabase.from('profiles').insert(profile.toJson());
      _userProfile = profile;
      notifyListeners();
      debugPrint('ProfileService: Profile inserted.');
    } on PostgrestException catch (e) {
      debugPrint('ProfileService: Postgrest error inserting profile: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('ProfileService: Unexpected error inserting profile: $e\n$stack');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<UserProfile>> fetchAllUserProfiles() async {
    _setLoading(true);
    try {
      final response = await _supabase.from('profiles').select();
      final List<UserProfile> profiles = (response as List).map((json) => UserProfile.fromJson(json)).toList();
      debugPrint('ProfileService: Fetched ${profiles.length} user profiles.');
      return profiles;
    } catch (e, stack) {
      debugPrint('ProfileService: Error fetching all user profiles: $e\n$stack');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<String> generateDummyUsers(int count) async {
    _setLoading(true);
    try {
      final uuid = Uuid();
      for (int i = 0; i < count; i++) {
        final dummyId = uuid.v4();
        final dummyEmail = 'dummy_user_${DateTime.now().millisecondsSinceEpoch}_$i@example.com';
        final dummyProfile = UserProfile(
          id: dummyId,
          email: dummyEmail,
          displayName: 'Dummy User $i',
          createdAt: DateTime.now().toUtc(),
          isPhase1Complete: true,
          isPhase2Complete: true,
        );
        await _supabase.from('profiles').insert(dummyProfile.toJson());
        debugPrint('Generated dummy user: $dummyEmail');
      }
      return 'Successfully generated $count dummy users.';
    } catch (e, stack) {
      debugPrint('ProfileService: Error generating dummy users: $e\n$stack');
      return 'Failed to generate dummy users: $e';
    } finally {
      _setLoading(false);
    }
  }
}