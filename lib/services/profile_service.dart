// lib/services/profile_service.dart
import 'dart:io'; // Needed for File class, though XFile is often used
import 'dart:typed_data';

import 'package:bliindaidating/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:path/path.dart' as p; // For path.extension
import 'package:image_picker/image_picker.dart'; // <--- ADD THIS IMPORT FOR XFile

class ProfileService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cached user profile
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  // Added a clearProfile method
  void clearProfile() {
    _userProfile = null;
    notifyListeners();
    debugPrint('User profile cleared from cache.');
  }

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        notifyListeners();
        return _userProfile;
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('rows not found')) {
        debugPrint('No profile found for user $userId. This is expected for new users.');
        _userProfile = null; // Ensure cached profile is null if not found
        notifyListeners();
        return null;
      }
      debugPrint('Error fetching user profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred while fetching profile: $e');
      rethrow;
    }
    return null;
  }

  // New method for inserting a new profile
  Future<void> insertProfile({
    required String userId,
    required String email,
    String? fullLegalName,
    String? displayName,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? locationZipCode,
    String? genderIdentity,
    String? sexualOrientation,
    double? heightCm,
    List<String>? hobbiesAndInterests,
    String? lookingFor,
    bool isPhase1Complete = false,
    bool isPhase2Complete = false,
    bool agreedToTerms = false,
    bool agreedToCommunityGuidelines = false,
    // Add other fields relevant for initial insert here, ensuring they are nullable
    String? bio,
    String? ethnicity,
    List<String>? languagesSpoken,
    String? desiredOccupation,
    String? educationLevel,
    List<String>? loveLanguages,
    List<String>? favoriteMedia,
    String? maritalStatus,
    bool? hasChildren,
    bool? wantsChildren,
    String? relationshipGoals,
    List<String>? dealbreakers,
    String? religionOrSpiritualBeliefs,
    String? politicalViews,
    String? diet,
    String? smokingHabits,
    String? drinkingHabits,
    String? exerciseFrequencyOrFitnessLevel,
    String? sleepSchedule,
    List<String>? personalityTraits,
    Map<String, dynamic>? questionnaireAnswers,
    Map<String, dynamic>? personalityAssessmentResults,
    bool? willingToRelocate,
    String? monogamyVsPolyamoryPreferences,
    String? astrologicalSign,
    String? attachmentStyle,
    String? communicationStyle,
    String? mentalHealthDisclosures,
    String? petOwnership,
    String? travelFrequencyOrFavoriteDestinations,
    Map<String, bool>? profileVisibilityPreferences,
    Map<String, bool>? pushNotificationPreferences,
  }) async {
    final now = DateTime.now();
    final profileData = {
      'user_id': userId,
      'email': email,
      'full_legal_name': fullLegalName,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'location_zip_code': locationZipCode,
      'gender_identity': genderIdentity,
      'sexual_orientation': sexualOrientation,
      'height_cm': heightCm,
      'hobbies_and_interests': hobbiesAndInterests,
      'looking_for': lookingFor,
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      // Include other fields if they are part of the initial insert flow
      'bio': bio,
      'ethnicity': ethnicity,
      'languages_spoken': languagesSpoken,
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'love_languages': loveLanguages,
      'favorite_media': favoriteMedia,
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'relationship_goals': relationshipGoals,
      'dealbreakers': dealbreakers,
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exercise_frequency_or_fitness_level': exerciseFrequencyOrFitnessLevel,
      'sleep_schedule': sleepSchedule,
      'personality_traits': personalityTraits,
      'questionnaire_answers': questionnaireAnswers,
      'personality_assessment_results': personalityAssessmentResults,
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'pet_ownership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': profileVisibilityPreferences,
      'push_notification_preferences': pushNotificationPreferences,
    };

    // Remove null values to let Supabase use column defaults if any
    profileData.removeWhere((key, value) => value == null);

    try {
      final response = await _supabase.from('user_profiles').insert(profileData).select().single();
      _userProfile = UserProfile.fromJson(response);
      notifyListeners();
      debugPrint('Profile inserted successfully for user: $userId');
    } on PostgrestException catch (e) {
      debugPrint('Error inserting profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during profile insertion: $e');
      rethrow;
    }
  }

  // Refactored method for updating an existing profile
  Future<void> updateProfile({
    required String userId,
    String? fullLegalName,
    String? displayName,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? locationZipCode,
    String? genderIdentity,
    String? sexualOrientation,
    double? heightCm,
    String? governmentIdFrontUrl,
    String? governmentIdBackUrl,
    String? ethnicity,
    List<String>? languagesSpoken,
    String? desiredOccupation,
    String? educationLevel,
    List<String>? hobbiesAndInterests,
    List<String>? loveLanguages,
    List<String>? favoriteMedia,
    String? maritalStatus,
    bool? hasChildren,
    bool? wantsChildren,
    String? relationshipGoals,
    List<String>? dealbreakers,
    String? bio,
    String? lookingFor,
    String? religionOrSpiritualBeliefs,
    String? politicalViews,
    String? diet,
    String? smokingHabits,
    String? drinkingHabits,
    String? exerciseFrequencyOrFitnessLevel,
    String? sleepSchedule,
    List<String>? personalityTraits,
    Map<String, dynamic>? questionnaireAnswers,
    Map<String, dynamic>? personalityAssessmentResults,
    bool? willingToRelocate,
    String? monogamyVsPolyamoryPreferences,
    String? astrologicalSign,
    String? attachmentStyle,
    String? communicationStyle,
    String? mentalHealthDisclosures,
    String? petOwnership,
    String? travelFrequencyOrFavoriteDestinations,
    Map<String, bool>? profileVisibilityPreferences,
    Map<String, bool>? pushNotificationPreferences,
    bool? isPhase1Complete, // Allows updating this flag
    bool? isPhase2Complete, // Allows updating this flag
    bool? agreedToTerms, // Allows updating this flag
    bool? agreedToCommunityGuidelines, // Allows updating this flag
  }) async {
    if (_userProfile == null) {
      debugPrint('No cached user profile found. Cannot update.');
      // Optionally throw an error or fetch profile if it's expected to exist
      throw Exception('Attempted to update a non-existent profile.');
    }

    final Map<String, dynamic> updateData = {
      'full_legal_name': fullLegalName,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'location_zip_code': locationZipCode,
      'gender_identity': genderIdentity,
      'sexual_orientation': sexualOrientation,
      'height_cm': heightCm,
      'government_id_front_url': governmentIdFrontUrl,
      'government_id_back_url': governmentIdBackUrl,
      'ethnicity': ethnicity,
      'languages_spoken': languagesSpoken,
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'hobbies_and_interests': hobbiesAndInterests,
      'love_languages': loveLanguages,
      'favorite_media': favoriteMedia,
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'relationship_goals': relationshipGoals,
      'dealbreakers': dealbreakers,
      'bio': bio,
      'looking_for': lookingFor,
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exercise_frequency_or_fitness_level': exerciseFrequencyOrFitnessLevel,
      'sleep_schedule': sleepSchedule,
      'personality_traits': personalityTraits,
      'questionnaire_answers': questionnaireAnswers,
      'personality_assessment_results': personalityAssessmentResults,
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'petOwnership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': profileVisibilityPreferences,
      'push_notification_preferences': pushNotificationPreferences,
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'updated_at': DateTime.now().toIso8601String(), // Always update timestamp
    };

    // Remove null values to avoid overwriting existing data with null
    // Only include values that are explicitly provided (non-null)
    updateData.removeWhere((key, value) => value == null);

    // Special handling for lists/maps if they could be *cleared* by passing an empty list/map
    // If a list parameter is an empty list, we want to send it. `removeWhere((k,v) => v==null)` would keep it.
    // However, if the field is defined as `List<String>?`, and the incoming value is `null`, it's removed.
    // If the incoming value is `[]`, it's kept and sent as an empty list. This is the desired behavior.

    try {
      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        notifyListeners();
        debugPrint('Profile updated successfully for user: $userId');
      }
    } on PostgrestException catch (e) {
      debugPrint('Error updating profile: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during profile update: $e');
      rethrow;
    }
  }

  // This method remains for file uploads and can be used by other parts of the app
  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExtension = p.extension(imageFile.name); // Use p.extension
      final fileName = 'profile_analysis/$userId/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      final response = await _supabase.storage.from('profile_analysis_photos').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isNotEmpty) {
        final publicUrl = _supabase.storage.from('profile_analysis_photos').getPublicUrl(fileName);
        debugPrint('Analysis photo uploaded successfully: $publicUrl');
        return publicUrl;
      }
    } on StorageException catch (e) {
      debugPrint('Supabase Storage Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during photo upload: $e');
      rethrow;
    }
    return null;
  }
}