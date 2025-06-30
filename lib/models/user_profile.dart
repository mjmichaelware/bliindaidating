// lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  String? displayName;
  String? bio;
  String? gender;
  DateTime? dateOfBirth;
  List<String>? interests;
  List<String>? photos;
  bool profileComplete;
  int penaltyCount;
  String lookingFor; // 'short_term', 'long_term', 'friends'
  Timestamp createdAt;
  Timestamp? lastActive;
  Map<String, dynamic>? availability; // To store availability slots

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.interests,
    this.photos,
    this.profileComplete = false,
    this.penaltyCount = 0,
    this.lookingFor = '',
    required this.createdAt,
    this.lastActive,
    this.availability,
  });

  // Factory constructor to create a UserProfile from a Firestore DocumentSnapshot
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      bio: data['bio'],
      gender: data['gender'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      interests: (data['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      photos:
          (data['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      profileComplete: data['profileComplete'] ?? false,
      penaltyCount: data['penaltyCount'] ?? 0,
      lookingFor: data['lookingFor'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastActive: data['lastActive'],
      availability: data['availability'],
    );
  }

  // Convert UserProfile object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'gender': gender,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'interests': interests,
      'photos': photos,
      'profileComplete': profileComplete,
      'penaltyCount': penaltyCount,
      'lookingFor': lookingFor,
      'createdAt': createdAt, // Should only be set once on creation
      'lastActive': FieldValue.serverTimestamp(), // Update on every save
      'availability': availability,
    };
  }

  // Method to convert to a Map for updates (excludes fields that shouldn't change)
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> map = {
      'displayName': displayName,
      'bio': bio,
      'gender': gender,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'interests': interests,
      'photos': photos,
      'profileComplete': profileComplete,
      'penaltyCount': penaltyCount,
      'lookingFor': lookingFor,
      'lastActive': FieldValue.serverTimestamp(),
      'availability': availability,
    };
    // Remove null values so they don't overwrite existing data in Firestore
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
