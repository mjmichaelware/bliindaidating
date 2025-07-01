// lib/models/user_profile.dart
class UserProfile {
  final String id; // Corresponds to 'id' in DB (UUID from auth.users)
  final String? fullName; // Corresponds to 'full_name' in DB
  final DateTime? dateOfBirth; // Corresponds to 'date_of_birth' in DB
  final String? gender; // Corresponds to 'gender' in DB
  final String? bio; // Corresponds to 'bio' in DB
  final String? profilePictureUrl; // Corresponds to 'profile_picture_url' in DB
  final DateTime createdAt; // Corresponds to 'created_at' in DB

  UserProfile({
    required this.id,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.profilePictureUrl,
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
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper for updating properties immutably
  UserProfile copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
    );
  }
}