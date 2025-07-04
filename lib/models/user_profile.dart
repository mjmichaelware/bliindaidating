// lib/models/user_profile.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for User

class UserProfile {
  final String userId; // Corresponds to 'id' in DB (UUID from auth.users)
  final String email; // Corresponds to 'email' in DB (added as per your schema)
  final String? fullName; // Corresponds to 'full_name' in DB
  final String? displayName;
  final DateTime? dateOfBirth; // Corresponds to 'date_of_birth' in DB
  final String? gender; // Corresponds to 'gender' in DB
  final String? phoneNumber; // Corresponds to 'phone_number' in DB
  final String? addressZip; // Corresponds to 'address_zip' in DB
  final String? bio; // Corresponds to 'bio' in DB
  final String? profilePictureUrl; // Corrected: Renamed from avatarUrl to profilePictureUrl
  final bool isProfileComplete; // Corrected: Mapped to is_profile_complete in DB
  final List<String> interests; // Corresponds to 'interests' in DB (text[] array)
  final String? lookingFor; // Corresponds to 'looking_for' in DB
  final String? sexualOrientation; // Corresponds to 'sexual_orientation' in DB
  final double? height; // Corresponds to 'height' in DB (double precision)
  final bool agreedToTerms; // Corresponds to 'agreed_to_terms' in DB
  final bool agreedToCommunityGuidelines; // Corresponds to 'agreed_to_community_guidelines' in DB
  final DateTime createdAt; // Corresponds to 'created_at' in DB
  final DateTime? updatedAt; // Corrected: Renamed from last_updated to updated_at for consistency

  UserProfile({
    required this.userId,
    required this.email, // Now required as per DB schema
    this.fullName,
    this.displayName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.addressZip,
    this.bio,
    this.profilePictureUrl, // Renamed parameter
    this.isProfileComplete = false,
    this.interests = const [],
    this.lookingFor,
    this.sexualOrientation,
    this.height,
    this.agreedToTerms = false,
    this.agreedToCommunityGuidelines = false,
    required this.createdAt,
    this.updatedAt, // Renamed
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      displayName: json['display_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      gender: json['gender'] as String?,
      phoneNumber: json['phone_number'] as String?,
      addressZip: json['address_zip'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?, // Corrected: Match DB name
      isProfileComplete: (json['is_profile_complete'] ?? false) as bool, // Corrected: Match DB name
      interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lookingFor: json['looking_for'] as String?,
      sexualOrientation: json['sexual_orientation'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      agreedToTerms: (json['agreed_to_terms'] ?? false) as bool,
      agreedToCommunityGuidelines: (json['agreed_to_community_guidelines'] ?? false) as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null, // Corrected: Match DB name
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
      userId: user.id,
      email: user.email ?? '',
      fullName: user.email?.split('@').first,
      createdAt: parsedCreatedAt ?? DateTime.now(),
      isProfileComplete: false,
      interests: const [],
      bio: null,
      dateOfBirth: null,
      gender: null,
      lookingFor: null,
      profilePictureUrl: null, // Renamed
      displayName: null,
      phoneNumber: null,
      addressZip: null,
      sexualOrientation: null,
      height: null,
      agreedToTerms: false,
      agreedToCommunityGuidelines: false,
      updatedAt: null, // Renamed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'display_name': displayName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'phone_number': phoneNumber,
      'address_zip': addressZip,
      'bio': bio,
      'profile_picture_url': profilePictureUrl, // Corrected: Match DB name
      'profile_complete': isProfileComplete, // Corrected: Use profile_complete for DB
      'interests': interests,
      'looking_for': lookingFor,
      'sexual_orientation': sexualOrientation,
      'height': height,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(), // Corrected: Match DB name
    };
  }

  UserProfile copyWith({
    String? email,
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
    DateTime? updatedAt, // Renamed
  }) {
    return UserProfile(
      userId: userId,
      email: email ?? this.email,
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
      updatedAt: updatedAt ?? this.updatedAt, // Renamed
    );
  }
}