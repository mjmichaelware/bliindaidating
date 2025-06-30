// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart'; // NEW: Supabase import
import 'package:flutter/foundation.dart'; // Added for debugPrint

/// A service to handle user authentication with Supabase.
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Gets the current Supabase user.
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Signs in a user with email and password using Supabase Auth.
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Supabase sign-in response: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase sign-in error: ${e.message}');
      rethrow; // Re-throw to be caught by UI
    } catch (e) {
      debugPrint('Unexpected sign-in error: $e');
      rethrow;
    }
  }

  /// Registers a new user with email and password using Supabase Auth.
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('Supabase sign-up response: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase sign-up error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected sign-up error: $e');
      rethrow;
    }
  }

  /// Signs out the current user from Supabase Auth.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('Supabase user signed out.');
    } on AuthException catch (e) {
      debugPrint('Supabase sign-out error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected sign-out error: $e');
      rethrow;
    }
  }
}
