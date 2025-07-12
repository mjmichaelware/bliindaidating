// lib/models/user_profile.dart

import 'dart:convert'; // Required for jsonDecode and jsonEncode
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for 'User' type

class UserProfile {
  final String userId;
  final String email;

  // Phase 1 - Core Identity & Consent
  final String? fullLegalName; // From KYC
  final String? displayName;
  final String? profilePictureUrl; // For live selfie
  final DateTime? dateOfBirth; // For age verification
  final String? phoneNumber; // For SMS verification
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final String? locationCity; // From location for AI
  final String? locationState; // From location for AI
  final String? locationZipCode; // From location for AI, renamed for clarity
  final String? genderIdentity; // From comprehensive gender options
  final String? sexualOrientation;
  final double? heightCm; // Height in centimeters for clarity
  final bool isPhase1Complete; // NEW: Flag for Phase 1 completion

  // Phase 2 - Essential Matching Data & KYC Completion
  final String? governmentIdFrontUrl; // For ID verification
  final String? governmentIdBackUrl; // For ID verification
  final String? ethnicity;
  final List<String>? languagesSpoken; // Now nullable List<String>
  final String? desiredOccupation;
  final String? educationLevel;
  final List<String>? hobbiesAndInterests; // Now nullable List<String>
  final List<String>? loveLanguages; // Now nullable List<String>
  final List<String>? favoriteMedia; // Now nullable List<String>
  final String? maritalStatus;
  final bool? hasChildren; // Whether user has children
  final bool? wantsChildren; // Whether user wants children (NEW)
  final String? relationshipGoals;
  final List<String>? dealbreakers; // Now nullable List<String>
  final bool isPhase2Complete; // NEW: Flag for Phase 2 completion

  // Phase 3 - Progressive Profiling (Comprehensive Attributes)
  final String? bio; // General bio
  final String? lookingFor;
  final String? religionOrSpiritualBeliefs;
  final String? politicalViews;
  final String? diet;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? exerciseFrequencyOrFitnessLevel;
  final String? sleepSchedule;
  final List<String>? personalityTraits; // Now nullable List<String>
  final bool? willingToRelocate;
  final String? monogamyVsPolyamoryPreferences;
  final String? astrologicalSign;
  final String? attachmentStyle;
  final String? communicationStyle;
  final String? mentalHealthDisclosures;
  final String? petOwnership;
  final String? travelFrequencyOrFavoriteDestinations;
  final String? profileVisibilityPreferences;
  final Map<String, dynamic>? pushNotificationPreferences; // Now nullable Map
  final Map<String, dynamic>? questionnaireAnswers; // Now nullable Map
  final Map<String, dynamic>? personalityAssessmentResults; // Now nullable Map

  // Timestamps and other existing fields (kept for compatibility)
  final DateTime createdAt;
  final DateTime? updatedAt; // Renamed from lastUpdated for consistency with DB

  // Deprecated/Redundant fields (kept for now, but consider removing after full migration)
  final String? fullName; // Consider using fullLegalName instead
  final String? gender; // Consider using genderIdentity instead
  final String? addressZip; // Consider using locationZipCode instead
  final double? height; // Consider using heightCm instead
  final List<String>? interests; // Now nullable List<String>

  UserProfile({
    required this.userId,
    required this.email,

    // Phase 1
    this.fullLegalName,
    this.displayName,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.phoneNumber,
    required this.agreedToTerms,
    required this.agreedToCommunityGuidelines,
    this.locationCity,
    this.locationState,
    this.locationZipCode,
    this.genderIdentity,
    this.sexualOrientation,
    this.heightCm,
    required this.isPhase1Complete, // NEW

    // Phase 2
    this.governmentIdFrontUrl,
    this.governmentIdBackUrl,
    this.ethnicity,
    this.languagesSpoken, // No default, now nullable
    this.desiredOccupation,
    this.educationLevel,
    this.hobbiesAndInterests, // No default, now nullable
    this.loveLanguages, // No default, now nullable
    this.favoriteMedia, // No default, now nullable
    this.maritalStatus,
    this.hasChildren,
    this.wantsChildren, // NEW
    this.relationshipGoals,
    this.dealbreakers, // No default, now nullable
    required this.isPhase2Complete, // NEW

    // Phase 3
    this.bio,
    this.lookingFor,
    this.religionOrSpiritualBeliefs,
    this.politicalViews,
    this.diet,
    this.smokingHabits,
    this.drinkingHabits,
    this.exerciseFrequencyOrFitnessLevel,
    this.sleepSchedule,
    this.personalityTraits, // No default, now nullable
    this.willingToRelocate,
    this.monogamyVsPolyamoryPreferences,
    this.astrologicalSign,
    this.attachmentStyle,
    this.communicationStyle,
    this.mentalHealthDisclosures,
    this.petOwnership,
    this.travelFrequencyOrFavoriteDestinations,
    this.profileVisibilityPreferences,
    this.pushNotificationPreferences,
    this.questionnaireAnswers, // NEW
    this.personalityAssessmentResults, // NEW

    // Timestamps and old fields for compatibility
    required this.createdAt,
    this.updatedAt,
    this.fullName, // Kept for compatibility
    this.gender, // Kept for compatibility
    this.addressZip, // Kept for compatibility
    this.interests, // No default, now nullable
    this.height, // Kept for compatibility
  });

  // Helper to parse PostgreSQL text array strings (e.g., "{item1,item2}" or "{}") into List<String>?
  // Returns null if the input is null, empty, or represents an empty array.
  static List<String>? _parseTextArray(String? text) {
    if (text == null || text.isEmpty || text == '{}') {
      return null; // Return null for empty or null strings/arrays
    }
    // Remove leading/trailing curly braces and split by comma
    final List<String> parsedList = text.substring(1, text.length - 1)
               .split(',')
               .map((e) => e.trim())
               .where((e) => e.isNotEmpty) // Filter out empty strings from potential trailing commas
               .toList();
    return parsedList.isEmpty ? null : parsedList; // Return null if list is empty after parsing
  }

  // Helper to convert List<String>? to PostgreSQL text array string format
  // Returns null if the list is null or empty.
  static String? _listToTextArrayString(List<String>? list) {
    if (list == null || list.isEmpty) {
      return null;
    }
    return '{${list.join(',')}}';
  }

  // Helper to parse JSON strings (e.g., "{"key":"value"}" or "{}") into Map<String, dynamic>?
  // Returns null if the input is null, empty, or parsing fails.
  static Map<String, dynamic>? _parseJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> parsedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return parsedMap.isEmpty ? null : parsedMap; // Return null if map is empty after parsing
    } catch (e) {
      debugPrint('Error parsing JSON string: $e - String: "$jsonString"');
      return null;
    }
  }

  // Helper to convert Map<String, dynamic>? to JSON string
  // Returns null if the map is null or empty.
  static String? _mapToJsonString(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return null;
    }
    return jsonEncode(map);
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] as String,
      email: json['email'] as String,

      // Phase 1
      fullLegalName: json['full_legal_name'] as String?,
      displayName: json['display_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false, // Ensure non-nullable with default
      agreedToCommunityGuidelines: json['agreed_to_community_guidelines'] as bool? ?? false, // Ensure non-nullable with default
      locationCity: json['location_city'] as String?,
      locationState: json['location_state'] as String?,
      locationZipCode: json['location_zip_code'] as String?,
      genderIdentity: json['gender_identity'] as String?,
      sexualOrientation: json['sexual_orientation'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      isPhase1Complete: json['is_phase1_complete'] as bool? ?? false, // NEW: With default for safety

      // Phase 2
      governmentIdFrontUrl: json['government_id_front_url'] as String?,
      governmentIdBackUrl: json['government_id_back_url'] as String?,
      ethnicity: json['ethnicity'] as String?,
      languagesSpoken: _parseTextArray(json['languages_spoken'] as String?), // Parse from String
      desiredOccupation: json['desired_occupation'] as String?,
      educationLevel: json['education_level'] as String?,
      hobbiesAndInterests: _parseTextArray(json['hobbies_and_interests'] as String?), // Corrected key, parse from String
      loveLanguages: _parseTextArray(json['love_languages'] as String?), // Corrected key, parse from String
      favoriteMedia: _parseTextArray(json['favorite_media'] as String?), // Parse from String
      maritalStatus: json['marital_status'] as String?,
      hasChildren: json['has_children'] as bool?,
      wantsChildren: json['wants_children'] as bool?, // NEW
      relationshipGoals: json['relationship_goals'] as String?,
      dealbreakers: _parseTextArray(json['dealbreakers'] as String?), // Parse from String
      isPhase2Complete: json['is_phase2_complete'] as bool? ?? false, // NEW: With default for safety

      // Phase 3
      bio: json['bio'] as String?,
      lookingFor: json['looking_for'] as String?,
      religionOrSpiritualBeliefs: json['religion_or_spiritual_beliefs'] as String?,
      politicalViews: json['political_views'] as String?,
      diet: json['diet'] as String?,
      smokingHabits: json['smoking_habits'] as String?,
      drinkingHabits: json['drinking_habits'] as String?,
      exerciseFrequencyOrFitnessLevel: json['exercise_frequency_or_fitness_level'] as String?,
      sleepSchedule: json['sleep_schedule'] as String?,
      personalityTraits: _parseTextArray(json['personality_traits'] as String?), // Parse from String
      willingToRelocate: json['willing_to_relocate'] as bool?,
      monogamyVsPolyamoryPreferences: json['monogamy_vs_polyamory_preferences'] as String?,
      astrologicalSign: json['astrological_sign'] as String?,
      attachmentStyle: json['attachment_style'] as String?,
      communicationStyle: json['communication_style'] as String?,
      mentalHealthDisclosures: json['mental_health_disclosures'] as String?,
      petOwnership: json['pet_ownership'] as String?,
      travelFrequencyOrFavoriteDestinations: json['travel_frequency_or_favorite_destinations'] as String?,
      profileVisibilityPreferences: json['profile_visibility_preferences'] as String?,
      pushNotificationPreferences: _parseJsonString(json['push_notification_preferences'] as String?), // Parse from String
      questionnaireAnswers: _parseJsonString(json['questionnaire_answers'] as String?), // NEW: Parse from String
      personalityAssessmentResults: _parseJsonString(json['personality_assessment_results'] as String?), // NEW: Parse from String

      // Timestamps and old fields for compatibility during migration
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      fullName: json['full_name'] as String?,
      gender: json['gender'] as String?,
      addressZip: json['address_zip'] as String?,
      interests: _parseTextArray(json['interests'] as String?), // Parse from String
      height: (json['height'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,

      // Phase 1
      'full_legal_name': fullLegalName,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'location_city': locationCity,
      'location_state': locationState,
      'location_zip_code': locationZipCode,
      'gender_identity': genderIdentity,
      'sexual_orientation': sexualOrientation,
      'height_cm': heightCm,
      'is_phase1_complete': isPhase1Complete, // NEW

      // Phase 2
      'government_id_front_url': governmentIdFrontUrl,
      'government_id_back_url': governmentIdBackUrl,
      'ethnicity': ethnicity,
      'languages_spoken': _listToTextArrayString(languagesSpoken), // Convert to String
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'hobbies_and_interests': _listToTextArrayString(hobbiesAndInterests), // Corrected key, convert to String
      'love_languages': _listToTextArrayString(loveLanguages), // Corrected key, convert to String
      'favorite_media': _listToTextArrayString(favoriteMedia), // Convert to String
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren, // NEW
      'relationship_goals': relationshipGoals,
      'dealbreakers': _listToTextArrayString(dealbreakers), // Convert to String
      'is_phase2_complete': isPhase2Complete, // NEW

      // Phase 3
      'bio': bio,
      'looking_for': lookingFor,
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exerciseFrequencyOrFitnessLevel': exerciseFrequencyOrFitnessLevel,
      'sleepSchedule': sleepSchedule,
      'personality_traits': _listToTextArrayString(personalityTraits), // Convert to String
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'pet_ownership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': profileVisibilityPreferences,
      'push_notification_preferences': _mapToJsonString(pushNotificationPreferences), // Convert to String
      'questionnaire_answers': _mapToJsonString(questionnaireAnswers), // NEW: Convert to String
      'personality_assessment_results': _mapToJsonString(personalityAssessmentResults), // NEW: Convert to String

      // Timestamps and old fields for compatibility during migration
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'full_name': fullName,
      'gender': gender,
      'address_zip': addressZip,
      'interests': _listToTextArrayString(interests), // Convert to String
      'height': height,
    };
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? fullLegalName,
    String? displayName,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
    String? locationCity,
    String? locationState,
    String? locationZipCode,
    String? genderIdentity,
    String? sexualOrientation,
    double? heightCm,
    bool? isPhase1Complete,
    String? governmentIdFrontUrl,
    String? governmentIdBackUrl,
    String? ethnicity,
    List<String>? languagesSpoken,
    String? desiredOccupation,
    String? educationLevel,
    List<String>? hobbiesAndInterests,
    List<String>? loveLanguages,
    List<String>? favoriteMedia, // Type changed to nullable List<String>
    String? maritalStatus,
    bool? hasChildren,
    bool? wantsChildren,
    String? relationshipGoals,
    List<String>? dealbreakers, // Type changed to nullable List<String>
    bool? isPhase2Complete,
    String? bio,
    String? lookingFor,
    String? religionOrSpiritualBeliefs,
    String? politicalViews,
    String? diet,
    String? smokingHabits,
    String? drinkingHabits,
    String? exerciseFrequencyOrFitnessLevel,
    String? sleepSchedule,
    List<String>? personalityTraits, // Type changed to nullable List<String>
    bool? willingToRelocate,
    String? monogamyVsPolyamoryPreferences,
    String? astrologicalSign,
    String? attachmentStyle,
    String? communicationStyle,
    String? mentalHealthDisclosures,
    String? petOwnership,
    String? travelFrequencyOrFavoriteDestinations,
    String? profileVisibilityPreferences,
    Map<String, dynamic>? pushNotificationPreferences,
    Map<String, dynamic>? questionnaireAnswers, // NEW
    Map<String, dynamic>? personalityAssessmentResults, // NEW
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? gender,
    String? addressZip,
    List<String>? interests, // Type changed to nullable List<String>
    double? height,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullLegalName: fullLegalName ?? this.fullLegalName,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToCommunityGuidelines: agreedToCommunityGuidelines ?? this.agreedToCommunityGuidelines,
      locationCity: locationCity ?? this.locationCity,
      locationState: locationState ?? this.locationState,
      locationZipCode: locationZipCode ?? this.locationZipCode,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      heightCm: heightCm ?? this.heightCm,
      isPhase1Complete: isPhase1Complete ?? this.isPhase1Complete,
      governmentIdFrontUrl: governmentIdFrontUrl ?? this.governmentIdFrontUrl,
      governmentIdBackUrl: governmentIdBackUrl ?? this.governmentIdBackUrl,
      ethnicity: ethnicity ?? this.ethnicity,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      desiredOccupation: desiredOccupation ?? this.desiredOccupation,
      educationLevel: educationLevel ?? this.educationLevel,
      hobbiesAndInterests: hobbiesAndInterests ?? this.hobbiesAndInterests,
      loveLanguages: loveLanguages ?? this.loveLanguages,
      favoriteMedia: favoriteMedia ?? this.favoriteMedia,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      wantsChildren: wantsChildren ?? this.wantsChildren,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      dealbreakers: dealbreakers ?? this.dealbreakers,
      isPhase2Complete: isPhase2Complete ?? this.isPhase2Complete,
      bio: bio ?? this.bio,
      lookingFor: lookingFor ?? this.lookingFor,
      religionOrSpiritualBeliefs: religionOrSpiritualBeliefs ?? this.religionOrSpiritualBeliefs,
      politicalViews: politicalViews ?? this.politicalViews,
      diet: diet ?? this.diet,
      smokingHabits: smokingHabits ?? this.smokingHabits,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      exerciseFrequencyOrFitnessLevel: exerciseFrequencyOrFitnessLevel ?? this.exerciseFrequencyOrFitnessLevel,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      willingToRelocate: willingToRelocate ?? this.willingToRelocate,
      monogamyVsPolyamoryPreferences: monogamyVsPolyamoryPreferences ?? this.monogamyVsPolyamoryPreferences,
      astrologicalSign: astrologicalSign ?? this.astrologicalSign,
      attachmentStyle: attachmentStyle ?? this.attachmentStyle,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      mentalHealthDisclosures: mentalHealthDisclosures ?? this.mentalHealthDisclosures,
      petOwnership: petOwnership ?? this.petOwnership,
      travelFrequencyOrFavoriteDestinations: travelFrequencyOrFavoriteDestinations ?? this.travelFrequencyOrFavoriteDestinations,
      profileVisibilityPreferences: profileVisibilityPreferences ?? this.profileVisibilityPreferences,
      pushNotificationPreferences: pushNotificationPreferences ?? this.pushNotificationPreferences,
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers, // NEW
      personalityAssessmentResults: personalityAssessmentResults ?? this.personalityAssessmentResults, // NEW
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      addressZip: addressZip ?? this.addressZip,
      interests: interests ?? this.interests,
      height: height ?? this.height,
    );
  }

  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      userId: user.id,
      email: user.email!,
      agreedToTerms: false, // Default to false, will be updated from DB
      agreedToCommunityGuidelines: false, // Default to false, will be updated from DB
      isPhase1Complete: false, // Default to false, will be updated from DB
      isPhase2Complete: false, // Default to false, will be updated from DB
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : DateTime.now(),
      // Initialize nullable List<String> fields as null
      languagesSpoken: null,
      hobbiesAndInterests: null,
      loveLanguages: null,
      favoriteMedia: null,
      dealbreakers: null,
      personalityTraits: null,
      interests: null, // For compatibility
      governmentIdFrontUrl: null,
      governmentIdBackUrl: null,
      questionnaireAnswers: null, // NEW
      personalityAssessmentResults: null, // NEW
    );
  }
}