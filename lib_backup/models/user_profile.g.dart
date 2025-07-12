// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullLegalName: json['fullLegalName'] as String?,
      displayName: json['displayName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      agreedToTerms: json['agreedToTerms'] as bool,
      agreedToCommunityGuidelines: json['agreedToCommunityGuidelines'] as bool,
      locationCity: json['locationCity'] as String?,
      locationState: json['locationState'] as String?,
      locationZipCode: json['locationZipCode'] as String?,
      genderIdentity: json['genderIdentity'] as String?,
      sexualOrientation: json['sexualOrientation'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      isPhase1Complete: json['isPhase1Complete'] as bool,
      governmentIdFrontUrl: json['governmentIdFrontUrl'] as String?,
      governmentIdBackUrl: json['governmentIdBackUrl'] as String?,
      ethnicity: json['ethnicity'] as String?,
      languagesSpoken: (json['languagesSpoken'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      desiredOccupation: json['desiredOccupation'] as String?,
      educationLevel: json['educationLevel'] as String?,
      hobbiesAndInterests: (json['hobbiesAndInterests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      loveLanguages: (json['loveLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      favoriteMedia: (json['favoriteMedia'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maritalStatus: json['maritalStatus'] as String?,
      hasChildren: json['hasChildren'] as bool?,
      wantsChildren: json['wantsChildren'] as bool?,
      relationshipGoals: json['relationshipGoals'] as String?,
      dealbreakers: (json['dealbreakers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPhase2Complete: json['isPhase2Complete'] as bool,
      questionnaireAnswers:
          json['questionnaireAnswers'] as Map<String, dynamic>?,
      personalityAssessmentResults:
          json['personalityAssessmentResults'] as Map<String, dynamic>?,
      bio: json['bio'] as String?,
      lookingFor: (json['lookingFor'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      religionOrSpiritualBeliefs: json['religionOrSpiritualBeliefs'] as String?,
      politicalViews: json['politicalViews'] as String?,
      diet: json['diet'] as String?,
      smokingHabits: json['smokingHabits'] as String?,
      drinkingHabits: json['drinkingHabits'] as String?,
      exerciseFrequencyOrFitnessLevel:
          json['exerciseFrequencyOrFitnessLevel'] as String?,
      sleepSchedule: json['sleepSchedule'] as String?,
      personalityTraits: (json['personalityTraits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      willingToRelocate: json['willingToRelocate'] as bool?,
      monogamyVsPolyamoryPreferences:
          json['monogamyVsPolyamoryPreferences'] as String?,
      astrologicalSign: json['astrologicalSign'] as String?,
      attachmentStyle: json['attachmentStyle'] as String?,
      communicationStyle: json['communicationStyle'] as String?,
      mentalHealthDisclosures: json['mentalHealthDisclosures'] as String?,
      petOwnership: json['petOwnership'] as String?,
      travelFrequencyOrFavoriteDestinations:
          json['travelFrequencyOrFavoriteDestinations'] as String?,
      profileVisibilityPreferences:
          json['profileVisibilityPreferences'] as String?,
      pushNotificationPreferences:
          json['pushNotificationPreferences'] as Map<String, dynamic>?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bodyType: json['bodyType'] as String?,
      hairType: json['hairType'] as String?,
      eyeColor: json['eyeColor'] as String?,
      healthStatus: json['healthStatus'] as String?,
      disabilities: (json['disabilities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      vaccinationStatus: json['vaccinationStatus'] as String?,
      relationshipType: json['relationshipType'] as String?,
      idealPartnerQualities: (json['idealPartnerQualities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      conflictResolutionStyle: json['conflictResolutionStyle'] as String?,
      numberOfSiblings: (json['numberOfSiblings'] as num?)?.toInt(),
      siblingsDescription: json['siblingsDescription'] as String?,
      culturalBackground: json['culturalBackground'] as String?,
      familyValues: (json['familyValues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      familyOrigin: json['familyOrigin'] as String?,
      personalityType: json['personalityType'] as String?,
      introvertExtrovertScale: json['introvertExtrovertScale'] as String?,
      emotionalIntelligenceLevel: json['emotionalIntelligenceLevel'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
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
      'id': instance.id,
      'email': instance.email,
      'fullLegalName': instance.fullLegalName,
      'displayName': instance.displayName,
      'profilePictureUrl': instance.profilePictureUrl,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'agreedToTerms': instance.agreedToTerms,
      'agreedToCommunityGuidelines': instance.agreedToCommunityGuidelines,
      'locationCity': instance.locationCity,
      'locationState': instance.locationState,
      'locationZipCode': instance.locationZipCode,
      'genderIdentity': instance.genderIdentity,
      'sexualOrientation': instance.sexualOrientation,
      'heightCm': instance?.heightCm,
      'isPhase1Complete': instance.isPhase1Complete,
      'governmentIdFrontUrl': instance.governmentIdFrontUrl,
      'governmentIdBackUrl': instance.governmentIdBackUrl,
      'ethnicity': instance.ethnicity,
      'languagesSpoken': instance.languagesSpoken,
      'desiredOccupation': instance.desiredOccupation,
      'educationLevel': instance.educationLevel,
      'hobbiesAndInterests': instance.hobbiesAndInterests,
      'loveLanguages': instance.loveLanguages,
      'favoriteMedia': instance.favoriteMedia,
      'maritalStatus': instance.maritalStatus,
      'hasChildren': instance.hasChildren,
      'wantsChildren': instance.wantsChildren,
      'relationshipGoals': instance.relationshipGoals,
      'dealbreakers': instance.dealbreakers,
      'isPhase2Complete': instance.isPhase2Complete,
      'questionnaireAnswers': instance.questionnaireAnswers,
      'personalityAssessmentResults': instance.personalityAssessmentResults,
      'bio': instance.bio,
      'lookingFor': instance.lookingFor,
      'religionOrSpiritualBeliefs': instance.religionOrSpiritualBeliefs,
      'politicalViews': instance.politicalViews,
      'diet': instance.diet,
      'smokingHabits': instance.smokingHabits,
      'drinkingHabits': instance.drinkingHabits,
      'exerciseFrequencyOrFitnessLevel':
          instance.exerciseFrequencyOrFitnessLevel,
      'sleepSchedule': instance.sleepSchedule,
      'personalityTraits': instance.personalityTraits,
      'willingToRelocate': instance.willingToRelocate,
      'monogamyVsPolyamoryPreferences': instance.monogamyVsPolyamoryPreferences,
      'astrologicalSign': instance.astrologicalSign,
      'attachmentStyle': instance.attachmentStyle,
      'communicationStyle': instance.communicationStyle,
      'mentalHealthDisclosures': instance.mentalHealthDisclosures,
      'petOwnership': instance.petOwnership,
      'travelFrequencyOrFavoriteDestinations':
          instance.travelFrequencyOrFavoriteDestinations,
      'profileVisibilityPreferences': instance.profileVisibilityPreferences,
      'pushNotificationPreferences': instance.pushNotificationPreferences,
      'weightKg': instance.weightKg,
      'bodyType': instance.bodyType,
      'hairType': instance.hairType,
      'eyeColor': instance.eyeColor,
      'healthStatus': instance.healthStatus,
      'disabilities': instance.disabilities,
      'vaccinationStatus': instance.vaccinationStatus,
      'relationshipType': instance.relationshipType,
      'idealPartnerQualities': instance.idealPartnerQualities,
      'conflictResolutionStyle': instance.conflictResolutionStyle,
      'numberOfSiblings': instance.numberOfSiblings,
      'siblingsDescription': instance.siblingsDescription,
      'culturalBackground': instance.culturalBackground,
      'familyValues': instance.familyValues,
      'familyOrigin': instance.familyOrigin,
      'personalityType': instance.personalityType,
      'introvertExtrovertScale': instance.introvertExtrovertScale,
      'emotionalIntelligenceLevel': instance.emotionalIntelligenceLevel,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'fullName': instance.fullName,
      'gender': instance.gender,
      'addressZip': instance.addressZip,
      'height': instance?.height,
      'interests': instance.interests,
    };
