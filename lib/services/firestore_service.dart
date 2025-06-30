// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ADDED: For debugPrint

/// A service class to handle all interactions with Cloud Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Updates or creates a user profile document in Firestore.
  ///
  /// [userId]: The ID of the user whose profile is being updated.
  ///           This should typically come from FirebaseAuth.currentUser.uid.
  /// [profileData]: A map containing the data to update/set in the user's profile.
  ///                Example: {'name': 'John Doe', 'bio': 'Loves Flutter'}.
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Reference to the user's document in the 'users' collection
      // You might want to structure your Firestore data differently,
      // e.g., 'profiles' collection, or a sub-collection under 'users'.
      // For simplicity, this assumes a top-level 'users' collection where
      // each document ID is the user's UID.
      await _db.collection('users').doc(userId).set(
        profileData,
        SetOptions(merge: true), // Use merge: true to update existing fields without overwriting the whole document
      );
      debugPrint('User profile $userId updated successfully in Firestore.'); // FIX: Replaced print with debugPrint
    } catch (e) {
      debugPrint('Error updating user profile in Firestore: $e'); // FIX: Replaced print with debugPrint
      rethrow; // Rethrow the exception so it can be caught by the calling widget
    }
  }

  // You can add more methods here for other Firestore operations, e.g.:
  // Future<Map<String, dynamic>?> getUserProfile(String userId) async { ... }
  // Future<void> addMatch(String userId, String matchedUserId) async { ... }
}
