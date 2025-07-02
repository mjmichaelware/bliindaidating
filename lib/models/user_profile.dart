// lib/models/user_profile.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for User

class UserProfile {
  final String userId; // Corresponds to 'id' in DB (UUID from auth.users)
  final String? fullName; // Corresponds to 'full_name' in DB
  final String? displayName; // NEW FIELD
  final DateTime? dateOfBirth; // Corresponds to 'date_of_birth' in DB
  final String? gender; // Corresponds to 'gender' in DB
  final String? phoneNumber; // NEW FIELD
  final String? addressZip; // NEW FIELD
  final String? bio; // Corresponds to 'bio' in DB
  final String? profilePictureUrl; // Corresponds to 'profile_picture_url' in DB (for analysis photo)
  final bool isProfileComplete; // Corresponds to 'is_profile_complete' in DB
  final List<String> interests; // Corresponds to 'interests' in DB (JSONB array)
  final String? lookingFor; // Corresponds to 'looking_for' in DB
  final String? sexualOrientation; // NEW FIELD
  final double? height; // NEW FIELD
  final bool agreedToTerms; // NEW FIELD
  final bool agreedToCommunityGuidelines; // NEW FIELD
  final DateTime createdAt; // Corresponds to 'created_at' in DB

  UserProfile({
    required this.userId, // Renamed from 'id' to 'userId' for clarity
    this.fullName,
    this.displayName, // NEW
    this.dateOfBirth,
    this.gender,
    this.phoneNumber, // NEW
    this.addressZip, // NEW
    this.bio,
    this.profilePictureUrl,
    this.isProfileComplete = false, // Default to false
    this.interests = const [], // Default to empty list
    this.lookingFor,
    this.sexualOrientation, // NEW
    this.height, // NEW
    this.agreedToTerms = false, // NEW default
    this.agreedToCommunityGuidelines = false, // NEW default
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String, // Expect 'user_id' from DB for consistency
      fullName: json['full_name'] as String?,
      displayName: json['display_name'] as String?, // NEW
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      gender: json['gender'] as String?,
      phoneNumber: json['phone_number'] as String?, // NEW
      addressZip: json['address_zip'] as String?, // NEW
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      isProfileComplete: (json['is_profile_complete'] ?? false) as bool,
      interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lookingFor: json['looking_for'] as String?,
      sexualOrientation: json['sexual_orientation'] as String?, // NEW
      height: (json['height'] as num?)?.toDouble(), // NEW
      agreedToTerms: (json['agreed_to_terms'] ?? false) as bool, // NEW
      agreedToCommunityGuidelines: (json['agreed_to_community_guidelines'] ?? false) as bool, // NEW
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory UserProfile.fromSupabaseUser(User user) {
    DateTime? parsedCreatedAt;
    if (user.createdAt is String) {
      parsedCreatedAt = DateTime.tryParse(user.createdAt as String);
    } else if (user.createdAt is DateTime) {
      parsedCreatedAt = user.createdAt as DateTime;
    }

    return UserProfile(
      userId: user.id, // Use userId
      fullName: user.email?.split('@').first,
      createdAt: parsedCreatedAt ?? DateTime.now(),
      isProfileComplete: false,
      interests: const [],
      bio: null,
      dateOfBirth: null,
      gender: null,
      lookingFor: null,
      profilePictureUrl: null,
      displayName: null,
      phoneNumber: null,
      addressZip: null,
      sexualOrientation: null,
      height: null,
      agreedToTerms: false,
      agreedToCommunityGuidelines: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId, // Use 'user_id' for DB column consistency
      'full_name': fullName,
      'display_name': displayName, // NEW
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone_number': phoneNumber, // NEW
      'address_zip': addressZip, // NEW
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'is_profile_complete': isProfileComplete,
      'interests': interests,
      'looking_for': lookingFor,
      'sexual_orientation': sexualOrientation, // NEW
      'height': height, // NEW
      'agreed_to_terms': agreedToTerms, // NEW
      'agreed_to_community_guidelines': agreedToCommunityGuidelines, // NEW
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(), // Explicitly update this
    };
  }

  // Helper for updating properties immutably
  UserProfile copyWith({
    String? fullName,
    String? displayName,
    DateTime? dateOfBirth,
    String? gender,
    String? phoneNumber,
    String? addressZip,
    String? bio,
    String? profilePictureUrl,
    bool? isProfileComplete,
    List<String>? interests,
    String? lookingFor,
    String? sexualOrientation,
    double? height,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
  }) {
    return UserProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressZip: addressZip ?? this.addressZip,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      interests: interests ?? this.interests,
      lookingFor: lookingFor ?? this.lookingFor,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      height: height ?? this.height,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToCommunityGuidelines: agreedToCommunityGuidelines ?? this.agreedToCommunityGuidelines,
      createdAt: createdAt,
    );
  }
}