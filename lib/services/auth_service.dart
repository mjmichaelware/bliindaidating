// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to authentication state changes (user logged in/out)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // --- Anonymous Sign-in (Optional, for testing or specific features) ---
  Future<UserCredential?> signInAnon() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      debugPrint("Signed in anonymously: ${userCredential.user?.uid}");
      return userCredential;
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      return null;
    }
  }

  // --- Email & Password Sign Up ---
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Immediately after successful sign-up, create a basic user document in Firestore.
      // This is also handled by a Cloud Function (auth_triggers.py) for robustness,
      // but client-side creation ensures immediate availability for profile setup.
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': userCredential.user?.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false, // Flag for onboarding flow
        'penaltyCount': 0, // Initialize penalty count for the dating app
        'lookingFor':
            '', // 'short_term', 'long_term', 'friends' - will be set during onboarding
      });
      debugPrint(
          "User signed up and basic profile created: ${userCredential.user?.uid}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          "Firebase Auth Error during sign up: ${e.code} - ${e.message}");
      // Re-throw to be caught by UI for specific error messages
      rethrow;
    } catch (e) {
      debugPrint("General Error during sign up: $e");
      rethrow;
    }
  }

  // --- Email & Password Sign In ---
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("User signed in: ${userCredential.user?.uid}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          "Firebase Auth Error during sign in: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("General Error during sign in: $e");
      rethrow;
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("User signed out.");
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // --- Get current user ---
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
