// lib/models/user_profile.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for User

class UserProfile {
  final String id; // Corresponds to 'id' in DB (UUID from auth.users)
  final String? fullName; // Corresponds to 'full_name' in DB
  final DateTime? dateOfBirth; // Corresponds to 'date_of_birth' in DB
  final String? gender; // Corresponds to 'gender' in DB
  final String? bio; // Corresponds to 'bio' in DB
  final String? profilePictureUrl; // Corresponds to 'profile_picture_url' in DB
  final bool isProfileComplete; // Corresponds to 'is_profile_complete' in DB
  final List<String> interests; // Corresponds to 'interests' in DB (JSONB array)
  final String? lookingFor; // Corresponds to 'looking_for' in DB
  final DateTime createdAt; // Corresponds to 'created_at' in DB

  UserProfile({
    required this.id,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.profilePictureUrl,
    this.isProfileComplete = false, // Default to false
    this.interests = const [], // Default to empty list
    this.lookingFor,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      isProfileComplete: (json['is_profile_complete'] ?? false) as bool,
      interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lookingFor: json['looking_for'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // New factory constructor to create a basic UserProfile from a Supabase User object.
  // This is useful for initial profile creation or fallback.
  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      id: user.id,
      // You might want to populate fullName from user.email or user.userMetadata
      fullName: user.email?.split('@').first, // Example: Use email prefix as default name
      createdAt: user.createdAt ?? DateTime.now(), // Use user.createdAt or current time
      isProfileComplete: false, // Assume not complete until user fills out form
      interests: const [],
      bio: null,
      dateOfBirth: null,
      gender: null,
      lookingFor: null,
      profilePictureUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'is_profile_complete': isProfileComplete,
      'interests': interests,
      'looking_for': lookingFor,
      'created_at': createdAt.toIso8601String(),
      // 'updated_at' is typically managed by the database trigger or upsert operation,
      // but if you explicitly update it in Dart, add it here:
      // 'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Helper for updating properties immutably
  UserProfile copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePictureUrl,
    bool? isProfileComplete,
    List<String>? interests,
    String? lookingFor,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      interests: interests ?? this.interests,
      lookingFor: lookingFor ?? this.lookingFor,
      createdAt: createdAt,
    );
  }
}