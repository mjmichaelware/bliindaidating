// lib/models/user_profile.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for 'User' type

class UserProfile {
  final String userId;
  final String email;
  final String? fullName;
  final String? displayName;
  final String? profilePictureUrl;
  final String? bio;
  final String? lookingFor;
  final bool isProfileComplete;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? addressZip;
  final List<String> interests;
  final String? sexualOrientation;
  final double? height;
  final bool agreedToTerms;
  final bool agreedToCommunityGuidelines;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  UserProfile({
    required this.userId,
    required this.email,
    this.fullName,
    this.displayName,
    this.profilePictureUrl,
    this.bio,
    this.lookingFor,
    required this.isProfileComplete,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.addressZip,
    this.interests = const [],
    this.sexualOrientation,
    this.height,
    required this.agreedToTerms,
    required this.agreedToCommunityGuidelines,
    required this.createdAt,
    this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      displayName: json['display_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      lookingFor: json['looking_for'] as String?,
      isProfileComplete: json['profile_complete'] as bool,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
      addressZip: json['address_zip'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      sexualOrientation: json['sexual_orientation'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      agreedToTerms: json['agreed_to_terms'] as bool,
      agreedToCommunityGuidelines: json['agreed_to_community_guidelines'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'looking_for': lookingFor,
      'is_profile_complete': isProfileComplete,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'address_zip': addressZip,
      'interests': interests,
      'sexual_orientation': sexualOrientation,
      'height': height,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_community_guidelines': agreedToCommunityGuidelines,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? displayName,
    String? profilePictureUrl,
    String? bio,
    String? lookingFor,
    bool? isProfileComplete,
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? addressZip,
    List<String>? interests,
    String? sexualOrientation,
    double? height,
    bool? agreedToTerms,
    bool? agreedToCommunityGuidelines,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      lookingFor: lookingFor ?? this.lookingFor,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressZip: addressZip ?? this.addressZip,
      interests: interests ?? this.interests,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      height: height ?? this.height,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToCommunityGuidelines: agreedToCommunityGuidelines ?? this.agreedToCommunityGuidelines,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory UserProfile.fromSupabaseUser(User user) {
    return UserProfile(
      userId: user.id,
      email: user.email!,
      isProfileComplete: false,
      agreedToTerms: false,
      agreedToCommunityGuidelines: false,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : DateTime.now(),
    );
  }
}