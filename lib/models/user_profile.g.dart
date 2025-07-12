// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      fullLegalName: json['full_legal_name'] as String?,
      displayName: json['display_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      phoneNumber: json['phone_number'] as String?,
      locationZipCode: json['location_zip_code'] as String?,
      genderIdentity: json['gender_identity'] as String?,
      sexualOrientation: json['sexual_orientation'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      governmentIdFrontUrl: json['government_id_front_url'] as String?,
      governmentIdBackUrl: json['government_id_back_url'] as String?,
      ethnicity: json['ethnicity'] as String?,
      languagesSpoken: (json['languages_spoken'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      desiredOccupation: json['desired_occupation'] as String?,
      educationLevel: json['education_level'] as String?,
      hobbiesAndInterests: (json['hobbies_and_interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      loveLanguages: (json['love_languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      favoriteMedia: (json['favorite_media'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maritalStatus: json['marital_status'] as String?,
      hasChildren: json['has_children'] as bool?,
      wantsChildren: json['wants_children'] as bool?,
      relationshipGoals: json['relationship_goals'] as String?,
      dealbreakers: (json['dealbreakers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bio: json['bio'] as String?,
      lookingFor: json['looking_for'] as String?,
      religionOrSpiritualBeliefs:
          json['religion_or_spiritual_beliefs'] as String?,
      politicalViews: json['political_views'] as String?,
      diet: json['diet'] as String?,
      smokingHabits: json['smoking_habits'] as String?,
      drinkingHabits: json['drinking_habits'] as String?,
      exerciseFrequencyOrFitnessLevel:
          json['exercise_frequency_or_fitness_level'] as String?,
      sleepSchedule: json['sleep_schedule'] as String?,
      personalityTraits: (json['personality_traits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      questionnaireAnswers:
          json['questionnaire_answers'] as Map<String, dynamic>?,
      personalityAssessmentResults:
          json['personality_assessment_results'] as Map<String, dynamic>?,
      willingToRelocate: json['willing_to_relocate'] as bool?,
      monogamyVsPolyamoryPreferences:
          json['monogamy_vs_polyamory_preferences'] as String?,
      astrologicalSign: json['astrological_sign'] as String?,
      attachmentStyle: json['attachment_style'] as String?,
      communicationStyle: json['communication_style'] as String?,
      mentalHealthDisclosures: json['mental_health_disclosures'] as String?,
      petOwnership: json['pet_ownership'] as String?,
      travelFrequencyOrFavoriteDestinations:
          json['travel_frequency_or_favorite_destinations'] as String?,
      profileVisibilityPreferences:
          (json['profile_visibility_preferences'] as Map<String, dynamic>?)
              ?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      pushNotificationPreferences:
          (json['push_notification_preferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      isPhase1Complete: json['is_phase_1_complete'] as bool? ?? false,
      isPhase2Complete: json['is_phase_2_complete'] as bool? ?? false,
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false,
      agreedToCommunityGuidelines:
          json['agreed_to_community_guidelines'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      fullName: json['fullName'] as String?,
      gender: json['gender'] as String?,
      addressZip: json['addressZip'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'full_legal_name': instance.fullLegalName,
      'display_name': instance.displayName,
      'profile_picture_url': instance.profilePictureUrl,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'phone_number': instance.phoneNumber,
      'location_zip_code': instance.locationZipCode,
      'gender_identity': instance.genderIdentity,
      'sexual_orientation': instance.sexualOrientation,
      'height_cm': instance.heightCm,
      'government_id_front_url': instance.governmentIdFrontUrl,
      'government_id_back_url': instance.governmentIdBackUrl,
      'ethnicity': instance.ethnicity,
      'languages_spoken': instance.languagesSpoken,
      'desired_occupation': instance.desiredOccupation,
      'education_level': instance.educationLevel,
      'hobbies_and_interests': instance.hobbiesAndInterests,
      'love_languages': instance.loveLanguages,
      'favorite_media': instance.favoriteMedia,
      'marital_status': instance.maritalStatus,
      'has_children': instance.hasChildren,
      'wants_children': instance.wantsChildren,
      'relationship_goals': instance.relationshipGoals,
      'dealbreakers': instance.dealbreakers,
      'bio': instance.bio,
      'looking_for': instance.lookingFor,
      'religion_or_spiritual_beliefs': instance.religionOrSpiritualBeliefs,
      'political_views': instance.politicalViews,
      'diet': instance.diet,
      'smoking_habits': instance.smokingHabits,
      'drinking_habits': instance.drinkingHabits,
      'exercise_frequency_or_fitness_level':
          instance.exerciseFrequencyOrFitnessLevel,
      'sleep_schedule': instance.sleepSchedule,
      'personality_traits': instance.personalityTraits,
      'questionnaire_answers': instance.questionnaireAnswers,
      'personality_assessment_results': instance.personalityAssessmentResults,
      'willing_to_relocate': instance.willingToRelocate,
      'monogamy_vs_polyamory_preferences':
          instance.monogamyVsPolyamoryPreferences,
      'astrological_sign': instance.astrologicalSign,
      'attachment_style': instance.attachmentStyle,
      'communication_style': instance.communicationStyle,
      'mental_health_disclosures': instance.mentalHealthDisclosures,
      'pet_ownership': instance.petOwnership,
      'travel_frequency_or_favorite_destinations':
          instance.travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': instance.profileVisibilityPreferences,
      'push_notification_preferences': instance.pushNotificationPreferences,
      'is_phase_1_complete': instance.isPhase1Complete,
      'is_phase_2_complete': instance.isPhase2Complete,
      'agreed_to_terms': instance.agreedToTerms,
      'agreed_to_community_guidelines': instance.agreedToCommunityGuidelines,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'fullName': instance.fullName,
      'gender': instance.gender,
      'addressZip': instance.addressZip,
      'interests': instance.interests,
      'height': instance.height,
    };
