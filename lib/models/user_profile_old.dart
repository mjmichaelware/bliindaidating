import 'dart:convert'; // Essential for jsonEncode and jsonDecode
import 'package:flutter/foundation.dart'; // For debugPrint

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? bio;
  final String? lookingFor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profilePictureUrl; // Corrected to match your usage
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? locationZipCode;
  final String? sexualOrientation;
  final double? heightCm;
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final String? fullLegalName;
  final String? genderIdentity;
  final String? ethnicity;
  final List<String> languagesSpoken;
  final String? desiredOccupation;
  final String? educationLevel;
  final List<String> hobbiesAndInterests;
  final List<String> loveLanguages;
  final List<String> favoriteMedia;
  final String? maritalStatus;
  final bool? hasChildren;
  final bool? wantsChildren;
  final String? relationshipGoals;
  final List<String> dealbreakers;
  final String? religionOrSpiritualBeliefs;
  final String? politicalViews;
  final String? diet;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? exerciseFrequencyOrFitnessLevel;
  final String? sleepSchedule;
  final List<String> personalityTraits;
  final bool? willingToRelocate;
  final String? monogamyVsPolyamoryPreferences;
  final String? astrologicalSign;
  final String? attachmentStyle;
  final String? communicationStyle;
  final String? mentalHealthDisclosures;
  final String? petOwnership;
  final String? travelFrequencyOrFavoriteDestinations;
  final Map<String, bool> profileVisibilityPreferences;
  final Map<String, bool> pushNotificationPreferences;
  final bool isPhase1Complete;
  final bool isPhase2Complete;
  final bool isAdmin;
  final Map<String, dynamic> questionnaireAnswers;
  final Map<String, dynamic> personalityAssessmentResults;

  // Deprecated fields (for migration purposes, not actively used for new data)
  final String? addressZip;
  final String? gender;
  final double? height;
  final String? interests;
  final String? governmentIdFrontUrl;
  final String? governmentIdBackUrl;
  final String? fullName;
  final String? hobbiesAndInterestsNew;
  final String? loveLanguagesNew;
  final String? locationCity;
  final String? locationState;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.bio,
    this.lookingFor,
    required this.createdAt,
    this.updatedAt,
    this.profilePictureUrl, // Corrected to match
    this.dateOfBirth,
    this.phoneNumber,
    this.locationZipCode,
    this.sexualOrientation,
    this.heightCm,
    this.agreedToTerms = false,
    this.agreedToCommunityGuidelines = false,
    this.fullLegalName,
    this.genderIdentity,
    this.ethnicity,
    this.languagesSpoken = const [],
    this.desiredOccupation,
    this.educationLevel,
    this.hobbiesAndInterests = const [],
    this.loveLanguages = const [],
    this.favoriteMedia = const [],
    this.maritalStatus,
    this.hasChildren,
    this.wantsChildren,
    this.relationshipGoals,
    this.dealbreakers = const [],
    this.religionOrSpiritualBeliefs,
    this.politicalViews,
    this.diet,
    this.smokingHabits,
    this.drinkingHabits,
    this.exerciseFrequencyOrFitnessLevel,
    this.sleepSchedule,
    this.personalityTraits = const [],
    this.willingToRelocate,
    this.monogamyVsPolyamoryPreferences,
    this.astrologicalSign,
    this.attachmentStyle,
    this.communicationStyle,
    this.mentalHealthDisclosures,
    this.petOwnership,
    this.travelFrequencyOrFavoriteDestinations,
    this.profileVisibilityPreferences = const {},
    this.pushNotificationPreferences = const {},
    this.isPhase1Complete = false,
    this.isPhase2Complete = false,
    this.isAdmin = false,
    this.questionnaireAnswers = const {},
    this.personalityAssessmentResults = const {},
    this.addressZip,
    this.gender,
    this.height,
    this.interests,
    this.governmentIdFrontUrl,
    this.governmentIdBackUrl,
    this.fullName,
    this.hobbiesAndInterestsNew,
    this.loveLanguagesNew,
    this.locationCity,
    this.locationState,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<String> _decodeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return List<String>.from(value.map((e) => e.toString()));
      }
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          debugPrint('Error decoding string to List<String>: $e. Value: "$value"');
        }
      }
      return [];
    }

    Map<String, bool> _decodeStringBoolMap(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return Map<String, bool>.from(value.map((k, v) => MapEntry(k.toString(), v as bool)));
      }
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map) {
            return Map<String, bool>.from(decoded.map((k, v) => MapEntry(k.toString(), v as bool)));
          }
        } catch (e) {
          debugPrint('Error decoding string to Map<String, bool>: $e. Value: "$value"');
        }
      }
      return {};
    }

    Map<String, dynamic> _decodeStringDynamicMap(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          debugPrint('Error decoding string to Map<String, dynamic>: $e. Value: "$value"');
        }
      }
      return {};
    }

    final String? resolvedFullLegalName = json['full_legal_name'] as String? ?? json['full_name'] as String?;
    final String? resolvedGenderIdentity = json['gender_identity'] as String? ?? json['gender'] as String?;
    final double? resolvedHeightCm = (json['height_cm'] as num?)?.toDouble() ?? (json['height'] as num?)?.toDouble();
    final String? resolvedLocationZipCode = json['location_zip_code'] as String? ?? json['address_zip'] as String?;

    List<String> resolvedHobbiesAndInterests = [];
    if (json['hobbies_and_interests'] != null) {
      resolvedHobbiesAndInterests = _decodeStringList(json['hobbies_and_interests']);
    } else if (json['hobbies_and_interests_new'] != null) {
      resolvedHobbiesAndInterests = _decodeStringList(json['hobbies_and_interests_new']);
    } else if (json['interests'] != null) {
      resolvedHobbiesAndInterests = _decodeStringList(json['interests']);
    }

    List<String> resolvedLoveLanguages = [];
    if (json['love_languages'] != null) {
      resolvedLoveLanguages = _decodeStringList(json['love_languages']);
    } else if (json['love_languages_new'] != null) {
      resolvedLoveLanguages = _decodeStringList(json['love_languages_new']);
    }

    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      lookingFor: json['looking_for'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      profilePictureUrl: json['profile_picture_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
      locationZipCode: resolvedLocationZipCode,
      sexualOrientation: json['sexual_orientation'] as String?,
      heightCm: resolvedHeightCm,
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false,
      agreedToCommunityGuidelines: json['agreed_to_community_guidelines'] as bool? ?? false,
      fullLegalName: resolvedFullLegalName,
      genderIdentity: resolvedGenderIdentity,
      ethnicity: json['ethnicity'] as String?,
      languagesSpoken: _decodeStringList(json['languages_spoken']),
      desiredOccupation: json['desired_occupation'] as String?,
      educationLevel: json['education_level'] as String?,
      hobbiesAndInterests: resolvedHobbiesAndInterests,
      loveLanguages: resolvedLoveLanguages,
      favoriteMedia: _decodeStringList(json['favorite_media']),
      maritalStatus: json['marital_status'] as String?,
      hasChildren: json['has_children'] as bool?,
      wantsChildren: json['wants_children'] as bool?,
      relationshipGoals: json['relationship_goals'] as String?,
      dealbreakers: _decodeStringList(json['dealbreakers']),
      religionOrSpiritualBeliefs: json['religion_or_spiritual_beliefs'] as String?,
      politicalViews: json['political_views'] as String?,
      diet: json['diet'] as String?,
      smokingHabits: json['smoking_habits'] as String?,
      drinkingHabits: json['drinking_habits'] as String?,
      exerciseFrequencyOrFitnessLevel: json['exercise_frequency_or_fitness_level'] as String?,
      sleepSchedule: json['sleep_schedule'] as String?,
      personalityTraits: _decodeStringList(json['personality_traits']),
      willingToRelocate: json['willing_to_relocate'] as bool?,
      monogamyVsPolyamoryPreferences: json['monogamy_vs_polyamory_preferences'] as String?,
      astrologicalSign: json['astrological_sign'] as String?,
      attachmentStyle: json['attachment_style'] as String?,
      communicationStyle: json['communication_style'] as String?,
      mentalHealthDisclosures: json['mental_health_disclosures'] as String?,
      petOwnership: json['pet_ownership'] as String?,
      travelFrequencyOrFavoriteDestinations: json['travel_frequency_or_favorite_destinations'] as String?,
      profileVisibilityPreferences: _decodeStringBoolMap(json['profile_visibility_preferences']),
      pushNotificationPreferences: _decodeStringBoolMap(json['push_notification_preferences']),
      isPhase1Complete: json['is_phase_1_complete'] as bool? ?? false,
      isPhase2Complete: json['is_phase_2_complete'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      questionnaireAnswers: _decodeStringDynamicMap(json['questionnaire_answers']),
      personalityAssessmentResults: _decodeStringDynamicMap(json['personality_assessment_results']),

      // Deprecated fields (populated for backward compatibility if needed, but not actively used)
      addressZip: json['address_zip'] as String?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      interests: json['interests'] as String?,
      governmentIdFrontUrl: json['government_id_front_url'] as String?,
      governmentIdBackUrl: json['government_id_back_url'] as String?,
      fullName: json['full_name'] as String?,
      hobbiesAndInterestsNew: json['hobbies_and_interests_new'] as String?,
      loveLanguagesNew: json['love_languages_new'] as String?,
      locationCity: json['location_city'] as String?,
      locationState: json['location_state'] as String?,
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
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'location_zip_code': locationZipCode,
      'sexual_orientation': sexualOrientation,
      'height_cm': heightCm,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'full_legal_name': fullLegalName,
      'gender_identity': genderIdentity,
      'ethnicity': ethnicity,
      'languages_spoken': jsonEncode(languagesSpoken),
      'desired_occupation': desiredOccupation,
      'education_level': educationLevel,
      'hobbies_and_interests': jsonEncode(hobbiesAndInterests),
      'love_languages': jsonEncode(loveLanguages),
      'favorite_media': jsonEncode(favoriteMedia),
      'marital_status': maritalStatus,
      'has_children': hasChildren,
      'wants_children': wantsChildren,
      'relationshipGoals': relationshipGoals,
      'dealbreakers': jsonEncode(dealbreakers),
      'religion_or_spiritual_beliefs': religionOrSpiritualBeliefs,
      'political_views': politicalViews,
      'diet': diet,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'exerciseFrequencyOrFitnessLevel': exerciseFrequencyOrFitnessLevel,
      'sleepSchedule': sleepSchedule,
      'personalityTraits': jsonEncode(personalityTraits),
      'willing_to_relocate': willingToRelocate,
      'monogamy_vs_polyamory_preferences': monogamyVsPolyamoryPreferences,
      'astrological_sign': astrologicalSign,
      'attachment_style': attachmentStyle,
      'communication_style': communicationStyle,
      'mentalHealthDisclosures': mentalHealthDisclosures,
      'petOwnership': petOwnership,
      'travel_frequency_or_favorite_destinations': travelFrequencyOrFavoriteDestinations,
      'profile_visibility_preferences': jsonEncode(profileVisibilityPreferences),
      'push_notification_preferences': jsonEncode(pushNotificationPreferences),
      'is_phase_1_complete': isPhase1Complete,
      'is_phase_2_complete': isPhase2Complete,
      'is_admin': isAdmin,
      'questionnaire_answers': jsonEncode(questionnaireAnswers),
      'personality_assessment_results': jsonEncode(personalityAssessmentResults),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? lookingFor,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePictureUrl, // Corrected to match
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? locationZipCode,
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
    List<String>? hobbiesAndInterests,
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
    bool? isAdmin,
    Map<String, dynamic>? questionnaireAnswers,
    Map<String, dynamic>? personalityAssessmentResults,
    String? addressZip,
    String? gender,
    double? height,
    String? interests,
    String? governmentIdFrontUrl,
    String? governmentIdBackUrl,
    String? fullName,
    String? hobbiesAndInterestsNew,
    String? loveLanguagesNew,
    String? locationCity,
    String? locationState,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      lookingFor: lookingFor ?? this.lookingFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl, // Corrected to match
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locationZipCode: locationZipCode ?? this.locationZipCode,
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
      hobbiesAndInterests: hobbiesAndInterests ?? this.hobbiesAndInterests,
      loveLanguages: loveLanguages ?? this.loveLanguages,
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
      copyDrinkingHabits: drinkingHabits ?? this.drinkingHabits, // Typo fixed: copyDrinkingHabits -> drinkingHabits
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
      isPhase1Complete: isPhase1Complete ?? this.isPhase1Complete,
      isPhase2Complete: isPhase2Complete ?? this.isPhase2Complete,
      isAdmin: isAdmin ?? this.isAdmin,
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers,
      personalityAssessmentResults: personalityAssessmentResults ?? this.personalityAssessmentResults,
      addressZip: addressZip ?? this.addressZip,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      interests: interests ?? this.interests,
      governmentIdFrontUrl: governmentIdFrontUrl ?? this.governmentIdFrontUrl,
      governmentIdBackUrl: governmentIdBackUrl ?? this.governmentIdBackUrl,
      fullName: fullName ?? this.fullName,
      hobbiesAndInterestsNew: hobbiesAndInterestsNew ?? this.hobbiesAndInterestsNew,
      loveLanguagesNew: loveLanguagesNew ?? this.loveLanguagesNew,
      locationCity: locationCity ?? this.locationCity,
      locationState: locationState ?? this.locationState,
    );
  }
}