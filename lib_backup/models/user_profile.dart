// lib/models/user_profile.dart

import 'package:supabase_flutter/supabase_flutter.dart'; // Required for 'User' type in fromSupabaseUser factory
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart'; // This line is crucial for json_serializable

@JsonSerializable(
  // Optional: You can specify explicit field naming conventions if your JSON keys
  // are different from your Dart property names (e.g., snake_case in JSON).
  // This is often a good idea for consistency with database column names.
  // fieldRename: FieldRename.snake,
)
class UserProfile {
  final String id; // Changed from id to id to match DB
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
  final bool isPhase1Complete; // Flag for Phase 1 completion

  // Phase 2 - Essential Matching Data & KYC Completion
  final String? governmentIdFrontUrl; // For ID verification
  final String? governmentIdBackUrl; // For ID verification
  final String? ethnicity;
  final List<String>? languagesSpoken; // Changed to List<String>?
  final String? desiredOccupation;
  final String? educationLevel;
  final List<String>? hobbiesAndInterests; // Changed to List<String>?
  final List<String>? loveLanguages; // EXISTING: Now assumed to be multi-select for forms
  final List<String>? favoriteMedia; // CHANGED TO LIST<STRING>!
  final String? maritalStatus;
  final bool? hasChildren; // Whether user has children
  final bool? wantsChildren; // Whether user wants children
  final String? relationshipGoals; // EXISTING: General goal
  final List<String>? dealbreakers; // EXISTING: Now assumed to be multi-select for forms
  final bool isPhase2Complete; // Flag for Phase 2 completion

  // NEW: Questionnaire & Personality Assessment Results (JSONB in DB)
  final Map<String, dynamic>? questionnaireAnswers;
  final Map<String, dynamic>? personalityAssessmentResults;

  // Phase 3 - Progressive Profiling (Comprehensive Attributes)
  final String? bio; // General bio
  final List<String>? lookingFor; // CHANGED FROM String? TO List<String>?
  final String? religionOrSpiritualBeliefs;
  final String? politicalViews;
  final String? diet;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? exerciseFrequencyOrFitnessLevel;
  final String? sleepSchedule;
  final List<String>? personalityTraits; // CHANGED TO LIST<STRING>!
  final bool? willingToRelocate;
  final String? monogamyVsPolyamoryPreferences;
  final String? astrologicalSign;
  final String? attachmentStyle;
  final String? communicationStyle; // EXISTING: Will be used for communication preference in forms
  final String? mentalHealthDisclosures;
  final String? petOwnership;
  final String? travelFrequencyOrFavoriteDestinations;
  final String? profileVisibilityPreferences;
  final Map<String, dynamic>? pushNotificationPreferences; // For user notification settings

  // NEWLY ADDED FIELDS from forms:
  final double? weightKg; // From PhysicalAttributesAndHealthForm
  final String? bodyType; // From PhysicalAttributesAndHealthForm
  final String? hairType; // From PhysicalAttributesAndHealthForm
  final String? eyeColor; // From PhysicalAttributesAndHealthForm
  final String? healthStatus; // From PhysicalAttributesAndHealthForm
  final List<String>? disabilities; // From PhysicalAttributesAndHealthForm (multi-select)
  final String? vaccinationStatus; // From PhysicalAttributesAndHealthForm

  final String? relationshipType; // From DatingAndRelationshipGoalsForm (e.g., "Long-term," "Casual")
  final List<String>? idealPartnerQualities; // From DatingAndRelationshipGoalsForm (multi-select)
  final String? conflictResolutionStyle; // From DatingAndRelationshipGoalsForm

  // Additional fields from general profile progression (implied from overall design)
  final int? numberOfSiblings;
  final String? siblingsDescription;
  final String? culturalBackground;
  final List<String>? familyValues; // multi-select
  final String? familyOrigin;

  final String? personalityType; // e.g., "Introvert", "Extrovert", "Ambivert"
  final String? introvertExtrovertScale; // e.g., "Strongly Introverted", "Slightly Extroverted"
  final String? emotionalIntelligenceLevel; // e.g., "High", "Medium", "Developing"

  // Timestamps and other existing fields (kept for compatibility)
  final DateTime createdAt;
  final DateTime? updatedAt; // Renamed from lastUpdated for consistency with DB

  // Deprecated/Redundant fields (kept for now, but consider removing after full migration)
  // These will be ignored in toJson but handled in fromJson for reading old data.
  // If you want json_serializable to ignore these fields during JSON conversion,
  // you can use @JsonKey(ignore: true) or @JsonKey(includeIfNull: false)
  // However, for fields you want to *read* from old JSON but not write,
  // it's better to manually handle them in fromJson if you weren't using json_serializable,
  // but since you are, they'll be included by default unless you ignore them.
  final String? fullName; // Consider using fullLegalName instead
  final String? gender; // Consider using genderIdentity instead
  final String? addressZip; // Consider using locationZipCode instead
  final double? height; // Consider using heightCm instead
  final List<String>? interests; // Consider using hobbiesAndInterests instead

  UserProfile({
    required this.id, // Changed from id
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
    this?.heightCm,
    required this.isPhase1Complete,

    // Phase 2
    this.governmentIdFrontUrl,
    this.governmentIdBackUrl,
    this.ethnicity,
    this.languagesSpoken,
    this.desiredOccupation,
    this.educationLevel,
    this.hobbiesAndInterests,
    this.loveLanguages,
    this.favoriteMedia,
    this.maritalStatus,
    this.hasChildren,
    this.wantsChildren,
    this.relationshipGoals,
    this.dealbreakers,
    required this.isPhase2Complete,

    // NEW: Questionnaire & Personality
    this.questionnaireAnswers,
    this.personalityAssessmentResults,

    // Phase 3
    this.bio,
    this.lookingFor, // Updated to List<String>?
    this.religionOrSpiritualBeliefs,
    this.politicalViews,
    this.diet,
    this.smokingHabits,
    this.drinkingHabits,
    this.exerciseFrequencyOrFitnessLevel,
    this.sleepSchedule,
    this.personalityTraits,
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

    // NEWLY ADDED FIELDS in this update
    this.weightKg,
    this.bodyType,
    this.hairType,
    this.eyeColor,
    this.healthStatus,
    this.disabilities,
    this.vaccinationStatus,
    this.relationshipType,
    this.idealPartnerQualities,
    this.conflictResolutionStyle,
    this.numberOfSiblings,
    this.siblingsDescription,
    this.culturalBackground,
    this.familyValues,
    this.familyOrigin,
    this.personalityType,
    this.introvertExtrovertScale,
    this.emotionalIntelligenceLevel,

    // Timestamps and old fields for compatibility
    required this.createdAt,
    this.updatedAt,
    this.fullName,
    this.gender,
    this.addressZip,
    this.interests,
    this?.height,
  });

  // Factory constructor for deserialization (from JSON) - THIS IS GENERATED
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  // Method for serialization (to JSON) - THIS IS GENERATED
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  // This factory constructor maps a Supabase User object to your UserProfile.
  // It handles initial default values for fields not present in the base Supabase User object.
  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      id: user.id,
      email: user.email!, // Email should generally be non-null for an authenticated user
      agreedToTerms: false, // Default to false, will be updated by user actions
      agreedToCommunityGuidelines: false, // Default to false
      isPhase1Complete: false, // Default
      isPhase2Complete: false, // Default
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : DateTime.now(), // Fallback to current time if createdAt is null (shouldn't be for Supabase User)
      // Initialize List<String> and Map<String, dynamic> fields as empty lists/maps
      // to avoid null checks where an empty list/map is acceptable.
      // If the database truly sends null for these and you want to reflect that,
      // you can keep them as null and use `?? []` or `?? {}` where accessed.
      languagesSpoken: [],
      hobbiesAndInterests: [],
      loveLanguages: [],
      favoriteMedia: [],
      dealbreakers: [],
      personalityTraits: [],
      interests: [], // For compatibility
      questionnaireAnswers: {},
      personalityAssessmentResults: {},
      pushNotificationPreferences: {},
      lookingFor: [],
      disabilities: [],
      idealPartnerQualities: [],
      familyValues: [],
    );
  }

  // CopyWith method for immutability and easy updates
  UserProfile copyWith({
    String? id,
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
    List<String>? favoriteMedia,
    String? maritalStatus,
    bool? hasChildren,
    bool? wantsChildren,
    String? relationshipGoals,
    List<String>? dealbreakers,
    bool? isPhase2Complete,
    Map<String, dynamic>? questionnaireAnswers,
    Map<String, dynamic>? personalityAssessmentResults,
    String? bio,
    List<String>? lookingFor,
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
    String? profileVisibilityPreferences,
    Map<String, dynamic>? pushNotificationPreferences,
    double? weightKg,
    String? bodyType,
    String? hairType,
    String? eyeColor,
    String? healthStatus,
    List<String>? disabilities,
    String? vaccinationStatus,
    String? relationshipType,
    List<String>? idealPartnerQualities,
    String? conflictResolutionStyle,
    int? numberOfSiblings,
    String? siblingsDescription,
    String? culturalBackground,
    List<String>? familyValues,
    String? familyOrigin,
    String? personalityType,
    String? introvertExtrovertScale,
    String? emotionalIntelligenceLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? gender,
    String? addressZip,
    List<String>? interests,
    double? height,
  }) {
    return UserProfile(
      id: id ?? this.id,
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
      heightCm: heightCm ?? this?.heightCm,
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
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers,
      personalityAssessmentResults: personalityAssessmentResults ?? this.personalityAssessmentResults,
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
      weightKg: weightKg ?? this.weightKg,
      bodyType: bodyType ?? this.bodyType,
      hairType: hairType ?? this.hairType,
      eyeColor: eyeColor ?? this.eyeColor,
      healthStatus: healthStatus ?? this.healthStatus,
      disabilities: disabilities ?? this.disabilities,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      relationshipType: relationshipType ?? this.relationshipType,
      idealPartnerQualities: idealPartnerQualities ?? this.idealPartnerQualities,
      conflictResolutionStyle: conflictResolutionStyle ?? this.conflictResolutionStyle,
      numberOfSiblings: numberOfSiblings ?? this.numberOfSiblings,
      siblingsDescription: siblingsDescription ?? this.siblingsDescription,
      culturalBackground: culturalBackground ?? this.culturalBackground,
      familyValues: familyValues ?? this.familyValues,
      familyOrigin: familyOrigin ?? this.familyOrigin,
      personalityType: personalityType ?? this.personalityType,
      introvertExtrovertScale: introvertExtrovertScale ?? this.introvertExtrovertScale,
      emotionalIntelligenceLevel: emotionalIntelligenceLevel ?? this.emotionalIntelligenceLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      addressZip: addressZip ?? this.addressZip,
      interests: interests ?? this.interests,
      height: height ?? this?.height,
    );
  }

  // Getter to determine Phase 2 completion status (data section)
  bool get isPhase2DataComplete {
    // Check all individual fields required for Phase 2 data completion
    return ethnicity != null &&
        (languagesSpoken?.isNotEmpty ?? false) &&
        desiredOccupation != null &&
        educationLevel != null &&
        (hobbiesAndInterests?.isNotEmpty ?? false) &&
        (loveLanguages?.isNotEmpty ?? false) &&
        (favoriteMedia?.isNotEmpty ?? false) &&
        maritalStatus != null &&
        hasChildren != null &&
        wantsChildren != null &&
        smokingHabits != null &&
        drinkingHabits != null &&
        (dealbreakers?.isNotEmpty ?? false) &&
        heightCm != null &&
        weightKg != null &&
        bodyType != null &&
        hairType != null &&
        eyeColor != null &&
        healthStatus != null &&
        vaccinationStatus != null &&
        // Note: Disabilities is optional, so not included in this "complete" check
        (lookingFor?.isNotEmpty ?? false) &&
        relationshipType != null &&
        (idealPartnerQualities?.isNotEmpty ?? false) &&
        conflictResolutionStyle != null &&
        communicationStyle != null &&
        numberOfSiblings != null &&
        culturalBackground != null &&
        (familyValues?.isNotEmpty ?? false) &&
        familyOrigin != null &&
        (bio?.isNotEmpty ?? false) &&
        personalityType != null &&
        introvertExtrovertScale != null &&
        emotionalIntelligenceLevel != null;
  }

  // Getter to determine if questionnaire answers are complete
  bool get isPhase2QuestionnaireComplete {
    return (questionnaireAnswers?.isNotEmpty ?? false) &&
           (personalityAssessmentResults?.isNotEmpty ?? false);
  }

  // Overall Phase 2 completion logic
  bool get isPhase2ProfileComplete {
    return isPhase2DataComplete && isPhase2QuestionnaireComplete;
  }
}