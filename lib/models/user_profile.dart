// lib/models/user_profile.dart
import 'package:supabase_flutter/supabase_flutter.dart'; // For User type if passed directly

class UserProfile {
  final String uid; // Supabase user ID (auth.uid())
  final String email;
  String display_name; // Renamed to snake_case
  String bio;
  String? gender;
  List<String> interests;
  String looking_for; // Renamed to snake_case
  bool profile_complete; // Renamed to snake_case
  DateTime created_at; // Renamed to snake_case
  DateTime? last_updated; // Renamed to snake_case
  String? avatar_url; // Renamed to snake_case

  UserProfile({
    required this.uid,
    required this.email,
    required this.display_name, // Renamed to snake_case
    required this.bio,
    this.gender,
    this.interests = const [],
    this.looking_for = '', // Renamed to snake_case
    this.profile_complete = false, // Renamed to snake_case
    required this.created_at, // Renamed to snake_case
    this.last_updated, // Renamed to snake_case
    this.avatar_url, // Renamed to snake_case
  });

  // Factory constructor to create UserProfile from a Supabase Auth User object
  // Useful for initial profile creation or when fetching user metadata directly from auth.currentUser
  factory UserProfile.fromSupabaseUser(User user) {
    // FIXED: Robustly handle createdAt and updatedAt from User object.
    // Explicitly check type and cast to DateTime, or fall back to parsing/now().
    final DateTime parsed_created_at = (user.createdAt is DateTime)
        ? (user.createdAt as DateTime)
        : DateTime.now(); // Fallback if user.createdAt is null or not DateTime

    DateTime? parsed_last_updated;
    if (user.updatedAt is DateTime) {
      parsed_last_updated = user.updatedAt as DateTime;
    } else if (user.userMetadata?['last_updated'] is String) {
      // Fallback to userMetadata for string, if needed
      parsed_last_updated = DateTime.tryParse(user.userMetadata!['last_updated'] as String);
    }
    // If it's null and not a string in metadata, it remains null.


    return UserProfile(
      uid: user.id,
      email: user.email ?? 'unknown@example.com',
      display_name: user.userMetadata?['display_name'] ?? '',
      bio: user.userMetadata?['bio'] ?? '',
      gender: user.userMetadata?['gender'],
      interests: List<String>.from(user.userMetadata?['interests'] ?? []),
      looking_for: user.userMetadata?['looking_for'] ?? '',
      profile_complete: user.userMetadata?['profile_complete'] ?? false,
      created_at: parsed_created_at,
      last_updated: parsed_last_updated,
      avatar_url: user.userMetadata?['avatar_url'],
    );
  }

  // Convert UserProfile to a Map for saving/upserting to Supabase 'profiles' table
  // Uses snake_case for column names to match PostgreSQL conventions (and now Dart properties)
  Map<String, dynamic> toMap() {
    return {
      'id': uid, // Maps to 'id' column in 'profiles' table (FK to auth.users.id)
      'email': email,
      'display_name': display_name, // Renamed to snake_case
      'bio': bio,
      'gender': gender,
      'interests': interests,
      'looking_for': looking_for, // Renamed to snake_case
      'profile_complete': profile_complete, // Renamed to snake_case
      'created_at': created_at.toIso8601String(), // Renamed to snake_case
      'last_updated': last_updated?.toIso8601String(), // Renamed to snake_case
      'avatar_url': avatar_url, // Renamed to snake_case
    };
  }

  // Factory constructor to create UserProfile from a Map (e.g., loaded from Supabase 'profiles' table)
  // Expects snake_case keys from the database (and now matches Dart properties)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['id'] as String,
      email: map['email'] as String,
      display_name: map['display_name'] as String,
      bio: map['bio'] as String,
      gender: map['gender'] as String?,
      interests: List<String>.from(map['interests'] as List? ?? []),
      looking_for: map['looking_for'] as String,
      profile_complete: map['profile_complete'] as bool,
      created_at: DateTime.parse(map['created_at'] as String),
      last_updated: map['last_updated'] != null ? DateTime.parse(map['last_updated'] as String) : null,
      avatar_url: map['avatar_url'] as String?,
    );
  }

  // Method to update current instance with new data (useful for creating copies with partial updates)
  UserProfile copyWith({
    String? display_name, // Renamed to snake_case
    String? bio,
    String? gender,
    List<String>? interests,
    String? looking_for, // Renamed to snake_case
    bool? profile_complete, // Renamed to snake_case
    String? avatar_url, // Renamed to snake_case
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      display_name: display_name ?? this.display_name, // Renamed to snake_case
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      looking_for: looking_for ?? this.looking_for, // Renamed to snake_case
      profile_complete: profile_complete ?? this.profile_complete, // Renamed to snake_case
      created_at: created_at, // Renamed to snake_case
      last_updated: DateTime.now(), // Always update last_updated on copyWith
      avatar_url: avatar_url ?? this.avatar_url, // Renamed to snake_case
    );
  }
}