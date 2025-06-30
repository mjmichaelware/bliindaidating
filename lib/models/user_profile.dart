// lib/models/user_profile.dart

class UserProfile {
  final String uid;
  final String email;
  String displayName;
  String bio;
  String? gender;
  List<String> interests;
  String lookingFor;
  bool profileComplete;
  DateTime createdAt;
  DateTime? lastUpdated;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.bio,
    this.gender,
    this.interests = const [],
    this.lookingFor = '',
    this.profileComplete = false,
    required this.createdAt,
    this.lastUpdated,
  });

  // Convert UserProfile to a Map for saving (e.g., to a generic backend or local storage)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'gender': gender,
      'interests': interests,
      'lookingFor': lookingFor,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to String for storage
      'lastUpdated': lastUpdated?.toIso8601String(), // Convert DateTime to String for storage
    };
  }

  // Convert UserProfile to a Map for updating (useful for partial updates)
  Map<String, dynamic> toUpdateMap() {
    final Map<String, dynamic> updateData = {
      'displayName': displayName,
      'bio': bio,
      'gender': gender,
      'interests': interests,
      'lookingFor': lookingFor,
      'profileComplete': profileComplete,
      'lastUpdated': DateTime.now().toIso8601String(), // Update timestamp
    };
    updateData.removeWhere((key, value) => value == null);
    return updateData;
  }

  // Factory constructor to create UserProfile from a Map (e.g., loaded from a backend)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      bio: map['bio'] as String,
      gender: map['gender'] as String?,
      interests: List<String>.from(map['interests'] as List),
      lookingFor: map['lookingFor'] as String,
      profileComplete: map['profileComplete'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated'] as String) : null,
    );
  }
}
