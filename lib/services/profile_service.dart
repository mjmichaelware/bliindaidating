// lib/services/profile_service.dart

import 'dart:io'; // Required for File on native platforms
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/models/user_profile.dart';
import 'package:image_picker/image_picker.dart'; // Import XFile

class ProfileService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  ProfileService() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.session?.user != null) {
        await fetchUserProfile(data.session!.user!.id);
      } else {
        clearProfile();
      }
    });
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      fetchUserProfile(currentUser.id);
    }
  }

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      debugPrint('Fetching profile for userId: $userId');
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        debugPrint('Profile fetched: ${_userProfile?.toJson()}');
      } else {
        _userProfile = null;
        debugPrint('No profile found for userId: $userId');
      }
      notifyListeners();
      return _userProfile;
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException fetching profile: ${e.message}');
      if (e.code == 'PGRST116') {
        _userProfile = null;
        notifyListeners();
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _userProfile = null;
      notifyListeners();
      return null;
    }
  }

  // MODIFIED: Accepts XFile instead of File
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final String path = 'avatars/$userId/${imageFile.name}'; // Use XFile.name for a better filename

      if (kIsWeb) {
        // For web, read as bytes
        final Uint8List bytes = await imageFile.readAsBytes();
        final response = await _supabase.storage.from('avatars').uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: imageFile.mimeType, // Use mimeType from XFile
              ),
            );
        return _supabase.storage.from('avatars').getPublicUrl(path); // Get public URL
      } else {
        // For native platforms, use File from dart:io
        final File file = File(imageFile.path); // Convert XFile to File using its path
        final response = await _supabase.storage.from('avatars').upload(
              path,
              file,
              fileOptions: FileOptions(
                upsert: true,
                contentType: imageFile.mimeType, // Use mimeType from XFile
              ),
            );
        return _supabase.storage.from('avatars').getPublicUrl(path); // Get public URL
      }
    } catch (e) {
      debugPrint('Error uploading analysis photo: $e');
      return null;
    }
  }

  Future<void> createOrUpdateProfile({required UserProfile profile}) async {
    debugPrint('Placeholder: createOrUpdateProfile called for ${profile.userId}');
    debugPrint('Profile data received: ${profile.toJson()}');
    _userProfile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
    debugPrint('Profile data cleared.');
  }

  Future<void> updateProfile({
    String? fullLegalName,
    String? displayName,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
    bool? isPhase1Complete,
    bool? isPhase2Complete,
  }) async {
    if (_userProfile == null) {
      debugPrint('ProfileService: Cannot update profile, no user profile loaded.');
      return;
    }

    final Map<String, dynamic> updates = {};
    if (fullLegalName != null) updates['full_legal_name'] = fullLegalName;
    if (displayName != null) updates['display_name'] = displayName;
    if (agreedToTerms != null) updates['agreed_to_terms'] = agreedToTerms;
    if (agreedToCommunityGuidelines != null) updates['agreed_to_community_guidelines'] = agreedToCommunityGuidelines;
    if (isPhase1Complete != null) updates['is_phase1_complete'] = isPhase1Complete;
    if (isPhase2Complete != null) updates['is_phase2_complete'] = isPhase2Complete;

    if (updates.isEmpty) {
      debugPrint('ProfileService: No updates provided.');
      return;
    }

    try {
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('user_id', _userProfile!.userId);

      _userProfile = _userProfile!.copyWith(
        fullLegalName: fullLegalName,
        displayName: displayName,
        agreedToTerms: agreedToTerms,
        agreedToCommunityGuidelines: agreedToCommunityGuidelines,
        isPhase1Complete: isPhase1Complete,
        isPhase2Complete: isPhase2Complete,
      );
      notifyListeners();
      debugPrint('ProfileService: User profile updated successfully.');
    } catch (e) {
      debugPrint('ProfileService: Error updating user profile: $e');
      rethrow;
    }
  }
}