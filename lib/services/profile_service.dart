// lib/services/profile_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert'; // Import for json.encode and json.decode

import 'package:bliindaidating/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

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
          .from('user_profiles') // Confirmed: Using 'user_profiles'
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        notifyListeners();
        debugPrint('Profile fetched successfully for user: $userId. Phase1: ${_userProfile?.isPhase1Complete}, Phase2: ${_userProfile?.isPhase2Complete}');
        return _userProfile;
      }
    } on PostgrestException catch (e) {
      // Supabase returns specific code 'PGRST116' and message '0 rows returned' for .single() when no rows are found
      if (e.code == 'PGRST116' || e.message.contains('0 rows returned')) {
        debugPrint('No profile found for user $userId. This is expected for new users or if profile creation is separate.');
        _userProfile = null; // Ensure cached profile is null if not found
        notifyListeners(); // Notify even if profile is not found
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
    List<String>? hobbiesAndInterests, // This is a List<String>
    String? lookingFor,
    bool isPhase1Complete = false,
    bool isPhase2Complete = false,
    bool agreedToTerms = false,
    bool agreedToCommunityGuidelines = false,
    String? bio,
    String? ethnicity,
    List<String>? languagesSpoken, // This is a List<String>
    String? desiredOccupation,
    String? educationLevel,
    List<String>? loveLanguages, // This is a List<String>
    List<String>? favoriteMedia, // This is a List<String>
    String? maritalStatus,
    bool? hasChildren,
    bool? wantsChildren,
    String? relationshipGoals,
    List<String>? dealbreakers, // This is a List<String>
    String? religionOrSpiritualBeliefs,
    String? politicalViews,
    String? diet,
    String? smokingHabits,
    String? drinkingHabits,
    String? exerciseFrequencyOrFitnessLevel,
    String? sleepSchedule,
    List<String>? personalityTraits, // This is a List<String>
    Map<String, dynamic>? questionnaireAnswers, // This is a Map
    Map<String, dynamic>? personalityAssessmentResults, // This is a Map
    bool? willingToRelocate,
    String? monogamyVsPolyamoryPreferences,
    String? astrologicalSign,
    String? attachmentStyle,
    String? communicationStyle,
    String? mentalHealthDisclosures,
    String? petOwnership,
    String? travelFrequencyOrFavoriteDestinations,
    Map<String, bool>? profileVisibilityPreferences, // This is a Map
    Map<String, bool>? pushNotificationPreferences, // This is a Map
  }) async {
    final now = DateTime.now();
    final profileData = {
      'id': userId,
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
      // CRITICAL FIX: JSON encode lists before sending to text columns
      'hobbies_and_interests': hobbiesAndInterests != null ? json.encode(hobbiesAndInterests) : null,
      'looking_for': lookingFor,
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'bio': bio,
      'ethnicity': ethnicity,
      'languages_spoken': languagesSpoken != null ? json.encode(languagesSpoken) : null,
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'love_languages': loveLanguages != null ? json.encode(loveLanguages) : null,
      'favorite_media': favoriteMedia != null ? json.encode(favoriteMedia) : null,
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'relationship_goals': relationshipGoals,
      'dealbreakers': dealbreakers != null ? json.encode(dealbreakers) : null,
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exercise_frequency_or_fitness_level': exerciseFrequencyOrFitnessLevel,
      'sleep_schedule': sleepSchedule,
      'personality_traits': personalityTraits != null ? json.encode(personalityTraits) : null,
      'questionnaire_answers': questionnaireAnswers != null ? json.encode(questionnaireAnswers) : null,
      'personality_assessment_results': personalityAssessmentResults != null ? json.encode(personalityAssessmentResults) : null,
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'pet_ownership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': profileVisibilityPreferences != null ? json.encode(profileVisibilityPreferences) : null,
      'push_notification_preferences': pushNotificationPreferences != null ? json.encode(pushNotificationPreferences) : null,
    };

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
    bool? isPhase1Complete,
    bool? isPhase2Complete,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
  }) async {
    if (_userProfile == null) {
      debugPrint('No cached user profile found. Cannot update. Attempting to fetch...');
      await fetchUserProfile(userId);
      if (_userProfile == null) {
        debugPrint('Still no user profile after attempted fetch. Cannot update.');
        throw Exception('Attempted to update a non-existent or un-fetchable profile.');
      }
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
      // CRITICAL FIX: JSON encode lists before sending to text columns
      'languages_spoken': languagesSpoken != null ? json.encode(languagesSpoken) : null,
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'hobbies_and_interests': hobbiesAndInterests != null ? json.encode(hobbiesAndInterests) : null,
      'love_languages': loveLanguages != null ? json.encode(loveLanguages) : null,
      'favorite_media': favoriteMedia != null ? json.encode(favoriteMedia) : null,
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'relationship_goals': relationshipGoals,
      'dealbreakers': dealbreakers != null ? json.encode(dealbreakers) : null,
      'bio': bio,
      'looking_for': lookingFor,
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exercise_frequency_or_fitness_level': exerciseFrequencyOrFitnessLevel,
      'sleep_schedule': sleepSchedule,
      'personality_traits': personalityTraits != null ? json.encode(personalityTraits) : null,
      'questionnaire_answers': questionnaireAnswers != null ? json.encode(questionnaireAnswers) : null,
      'personality_assessment_results': personalityAssessmentResults != null ? json.encode(personalityAssessmentResults) : null,
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'pet_ownership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': profileVisibilityPreferences != null ? json.encode(profileVisibilityPreferences) : null,
      'push_notification_preferences': pushNotificationPreferences != null ? json.encode(pushNotificationPreferences) : null,
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'updated_at': DateTime.now().toIso8601String(),
    };

    updateData.removeWhere((key, value) => value == null);

    try {
      final response = await _supabase
          .from('user_profiles') // Confirmed: Using 'user_profiles'
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      if (response != null) {
        _userProfile = UserProfile.fromJson(response);
        notifyListeners();
        debugPrint('Profile updated successfully for user: $userId. Phase1: ${_userProfile?.isPhase1Complete}, Phase2: ${_userProfile?.isPhase2Complete}');
      }
    } on PostgrestException catch (e) {
      debugPrint('Error updating profile: ${e.message}');
      notifyListeners(); // Notify even on error to ensure UI reflects potential failure or stale state
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred during profile update: $e');
      notifyListeners(); // Notify even on error
      rethrow;
    }
  }

  Future<String?> uploadAnalysisPhoto(String userId, XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExtension = p.extension(imageFile.name);
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