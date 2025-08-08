// lib/models/user_profile.dart

import 'package:flutter/material.dart';

@immutable
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? bio;
  final String? lookingFor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profilePictureUrl;
  final String? analysisPhotoUrl;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? locationZipCode;
  final String? locationCity;
  final String? locationState;
  final String? sexualOrientation;
  final double? heightCm;
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final String? fullLegalName;
  final String? genderIdentity;
  final String? ethnicity;
  final List<String>? languagesSpoken;
  final String? desiredOccupation;
  final String? educationLevel;
  final Map<String, dynamic>? favoriteMedia;
  final String? maritalStatus;
  final bool? hasChildren;
  final bool? wantsChildren;
  final String? relationshipGoals;
  final List<String>? dealbreakers;
  final String? religionOrSpiritualBeliefs;
  final String? politicalViews;
  final String? diet;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? exerciseFrequencyOrFitnessLevel;
  final String? sleepSchedule;
  final bool? willingToRelocate;
  final String? monogamyVsPolyamoryPreferences;
  final String? astrologicalSign;
  final String? attachmentStyle;
  final String? communicationStyle;
  final String? mentalHealthDisclosures;
  final String? petOwnership;
  final String? travelFrequencyOrFavoriteDestinations;
  final bool isPhase1Complete;
  final bool isPhase2Complete;
  final Map<String, dynamic>? hobbiesAndInterests;
  final Map<String, dynamic>? loveLanguages;
  final Map<String, dynamic>? questionnaireAnswers;
  final Map<String, dynamic>? personalityAssessmentResults;
  final Map<String, dynamic>? datingPreferences;
  final Map<String, bool>? profileVisibilityPreferences;
  final Map<String, bool>? pushNotificationPreferences;
  // NEW: Added fields from dummy data that were missing in constructor
  final String? governmentIdFrontUrl;
  final String? governmentIdBackUrl;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.bio,
    this.lookingFor,
    required this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
    this.analysisPhotoUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.locationZipCode,
    this.locationCity,
    this.locationState,
    this.sexualOrientation,
    this.heightCm,
    this.agreedToTerms = false,
    this.agreedToCommunityGuidelines = false,
    this.fullLegalName,
    this.genderIdentity,
    this.ethnicity,
    this.languagesSpoken,
    this.desiredOccupation,
    this.educationLevel,
    this.favoriteMedia,
    this.maritalStatus,
    this.hasChildren,
    this.wantsChildren,
    this.relationshipGoals,
    this.dealbreakers,
    this.religionOrSpiritualBeliefs,
    this.politicalViews,
    this.diet,
    this.smokingHabits,
    this.drinkingHabits,
    this.exerciseFrequencyOrFitnessLevel,
    this.sleepSchedule,
    this.willingToRelocate,
    this.monogamyVsPolyamoryPreferences,
    this.astrologicalSign,
    this.attachmentStyle,
    this.communicationStyle,
    this.mentalHealthDisclosures,
    this.petOwnership,
    this.travelFrequencyOrFavoriteDestinations,
    this.isPhase1Complete = false,
    this.isPhase2Complete = false,
    this.hobbiesAndInterests,
    this.loveLanguages,
    this.questionnaireAnswers,
    this.personalityAssessmentResults,
    this.datingPreferences,
    this.profileVisibilityPreferences,
    this.pushNotificationPreferences,
    this.governmentIdFrontUrl,
    this.governmentIdBackUrl,
  });

  // Getter to check if the entire profile setup is complete
  bool get isProfileSetupComplete => isPhase1Complete && isPhase2Complete;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? lookingFor,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePictureUrl,
    String? analysisPhotoUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? locationZipCode,
    String? locationCity,
    String? locationState,
    String? sexualOrientation,
    double? heightCm,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
    String? fullLegalName,
    String? genderIdentity,
    String? ethnicity,
    List<String>? languagesSpoken,
    String? desiredOccupation,
    String? educationLevel,
    Map<String, dynamic>? favoriteMedia,
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
    bool? willingToRelocate,
    String? monogamyVsPolyamoryPreferences,
    String? astrologicalSign,
    String? attachmentStyle,
    String? communicationStyle,
    String? mentalHealthDisclosures,
    String? petOwnership,
    String? travelFrequencyOrFavoriteDestinations,
    bool? isPhase1Complete,
    bool? isPhase2Complete,
    Map<String, dynamic>? hobbiesAndInterests,
    Map<String, dynamic>? loveLanguages,
    Map<String, dynamic>? questionnaireAnswers,
    Map<String, dynamic>? personalityAssessmentResults,
    Map<String, dynamic>? datingPreferences,
    Map<String, bool>? profileVisibilityPreferences,
    Map<String, bool>? pushNotificationPreferences,
    String? governmentIdFrontUrl,
    String? governmentIdBackUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      lookingFor: lookingFor ?? this.lookingFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      analysisPhotoUrl: analysisPhotoUrl ?? this.analysisPhotoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locationZipCode: locationZipCode ?? this.locationZipCode,
      locationCity: locationCity ?? this.locationCity,
      locationState: locationState ?? this.locationState,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      heightCm: heightCm ?? this.heightCm,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToCommunityGuidelines: agreedToCommunityGuidelines ?? this.agreedToCommunityGuidelines,
      fullLegalName: fullLegalName ?? this.fullLegalName,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      ethnicity: ethnicity ?? this.ethnicity,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      desiredOccupation: desiredOccupation ?? this.desiredOccupation,
      educationLevel: educationLevel ?? this.educationLevel,
      favoriteMedia: favoriteMedia ?? this.favoriteMedia,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      hasChildren: hasChildren ?? this.hasChildren,
      wantsChildren: wantsChildren ?? this.wantsChildren,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      dealbreakers: dealbreakers ?? this.dealbreakers,
      religionOrSpiritualBeliefs: religionOrSpiritualBeliefs ?? this.religionOrSpiritualBeliefs,
      politicalViews: politicalViews ?? this.politicalViews,
      diet: diet ?? this.diet,
      smokingHabits: smokingHabits ?? this.smokingHabits,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      exerciseFrequencyOrFitnessLevel: exerciseFrequencyOrFitnessLevel ?? this.exerciseFrequencyOrFitnessLevel,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      willingToRelocate: willingToRelocate ?? this.willingToRelocate,
      monogamyVsPolyamoryPreferences: monogamyVsPolyamoryPreferences ?? this.monogamyVsPolyamoryPreferences,
      astrologicalSign: astrologicalSign ?? this.astrologicalSign,
      attachmentStyle: attachmentStyle ?? this.attachmentStyle,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      mentalHealthDisclosures: mentalHealthDisclosures ?? this.mentalHealthDisclosures,
      petOwnership: petOwnership ?? this.petOwnership,
      travelFrequencyOrFavoriteDestinations: travelFrequencyOrFavoriteDestinations ?? this.travelFrequencyOrFavoriteDestinations,
      isPhase1Complete: isPhase1Complete ?? this.isPhase1Complete,
      isPhase2Complete: isPhase2Complete ?? this.isPhase2Complete,
      hobbiesAndInterests: hobbiesAndInterests ?? this.hobbiesAndInterests,
      loveLanguages: loveLanguages ?? this.loveLanguages,
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers,
      personalityAssessmentResults: personalityAssessmentResults ?? this.personalityAssessmentResults,
      datingPreferences: datingPreferences ?? this.datingPreferences,
      profileVisibilityPreferences: profileVisibilityPreferences ?? this.profileVisibilityPreferences,
      pushNotificationPreferences: pushNotificationPreferences ?? this.pushNotificationPreferences,
      governmentIdFrontUrl: governmentIdFrontUrl ?? this.governmentIdFrontUrl,
      governmentIdBackUrl: governmentIdBackUrl ?? this.governmentIdBackUrl,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      lookingFor: json['looking_for'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      profilePictureUrl: json['profile_picture_url'] as String?,
      analysisPhotoUrl: json['analysis_photo_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
      locationZipCode: json['location_zip_code'] as String?,
      locationCity: json['location_city'] as String?,
      locationState: json['location_state'] as String?,
      sexualOrientation: json['sexual_orientation'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false, // Handle null case
      agreedToCommunityGuidelines: json['agreed_to_community_guidelines'] as bool? ?? false, // Handle null case
      fullLegalName: json['full_legal_name'] as String?,
      genderIdentity: json['gender_identity'] as String?,
      ethnicity: json['ethnicity'] as String?,
      languagesSpoken: (json['languages_spoken'] as List?)?.map((e) => e as String).toList(),
      desiredOccupation: json['desired_occupation'] as String?,
      educationLevel: json['education_level'] as String?,
      favoriteMedia: json['favorite_media'] as Map<String, dynamic>?,
      maritalStatus: json['marital_status'] as String?,
      hasChildren: json['has_children'] as bool?,
      wantsChildren: json['wants_children'] as bool?,
      relationshipGoals: json['relationship_goals'] as String?,
      dealbreakers: (json['dealbreakers'] as List?)?.map((e) => e as String).toList(),
      religionOrSpiritualBeliefs: json['religion_or_spiritual_beliefs'] as String?,
      politicalViews: json['political_views'] as String?,
      diet: json['diet'] as String?,
      smokingHabits: json['smoking_habits'] as String?,
      drinkingHabits: json['drinking_habits'] as String?,
      exerciseFrequencyOrFitnessLevel: json['exercise_frequency_or_fitness_level'] as String?,
      sleepSchedule: json['sleep_schedule'] as String?,
      willingToRelocate: json['willing_to_relocate'] as bool?,
      monogamyVsPolyamoryPreferences: json['monogamy_vs_polyamory_preferences'] as String?,
      astrologicalSign: json['astrological_sign'] as String?,
      attachmentStyle: json['attachment_style'] as String?,
      communicationStyle: json['communication_style'] as String?,
      mentalHealthDisclosures: json['mental_health_disclosures'] as String?,
      petOwnership: json['pet_ownership'] as String?,
      travelFrequencyOrFavoriteDestinations: json['travel_frequency_or_favorite_destinations'] as String?,
      isPhase1Complete: json['is_phase_1_complete'] as bool? ?? false, // Handle null case
      isPhase2Complete: json['is_phase_2_complete'] as bool? ?? false, // Handle null case
      hobbiesAndInterests: json['hobbies_and_interests'] as Map<String, dynamic>?,
      loveLanguages: json['love_languages'] as Map<String, dynamic>?,
      questionnaireAnswers: json['questionnaire_answers'] as Map<String, dynamic>?,
      personalityAssessmentResults: json['personality_assessment_results'] as Map<String, dynamic>?,
      datingPreferences: json['dating_preferences'] as Map<String, dynamic>?,
      profileVisibilityPreferences: (json['profile_visibility_preferences'] as Map<String, dynamic>?)?.cast<String, bool>(),
      pushNotificationPreferences: (json['push_notification_preferences'] as Map<String, dynamic>?)?.cast<String, bool>(),
      // NEW: Added to fromJson
      governmentIdFrontUrl: json['government_id_front_url'] as String?,
      governmentIdBackUrl: json['government_id_back_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'bio': bio,
      'looking_for': lookingFor,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_picture_url': profilePictureUrl,
      'analysis_photo_url': analysisPhotoUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'location_zip_code': locationZipCode,
      'location_city': locationCity,
      'location_state': locationState,
      'sexual_orientation': sexualOrientation,
      'height_cm': heightCm,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'full_legal_name': fullLegalName,
      'gender_identity': genderIdentity,
      'ethnicity': ethnicity,
      'languages_spoken': languagesSpoken,
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
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
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mental_health_disclosures': mentalHealthDisclosures,
      'pet_ownership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'hobbies_and_interests': hobbiesAndInterests,
      'love_languages': loveLanguages,
      'questionnaire_answers': questionnaireAnswers,
      'personality_assessment_results': personalityAssessmentResults,
      'dating_preferences': datingPreferences,
      'profile_visibility_preferences': profileVisibilityPreferences,
      'push_notification_preferences': pushNotificationPreferences,
      // NEW: Added to toJson
      'government_id_front_url': governmentIdFrontUrl,
      'government_id_back_url': governmentIdBackUrl,
    };
  }
}