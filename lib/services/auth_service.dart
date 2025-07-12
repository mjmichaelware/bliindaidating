// lib/services/auth_service.dart
import 'package:bliindaidating/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import Provider

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('Auth event: $event');

      if (session != null) {
        _currentUser = session.user;
        debugPrint('User logged in: ${_currentUser?.id}');
      } else {
        _currentUser = null;
        debugPrint('User logged out.');
        // Optionally, clear profile data when user logs out
        // This assumes ProfileService is accessible, e.g., via Provider in a widget tree
        // For a service, it might be better to emit an event or have main.dart handle it.
        // If AuthService has a direct dependency on ProfileService, it should be passed in.
        // For simplicity and assuming Provider is available globally where this is used:
        // You might need to pass context or use a global key/locator for this if AuthService
        // is not created within a widget that has access to the Provider.
      }
      notifyListeners();
    });
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final AuthResponse response =
          await _supabase.auth.signUp(email: email, password: password);
      debugPrint('Sign up response: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign in response: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut(BuildContext context) async { // Added BuildContext
    try {
      await _supabase.auth.signOut();
      // Clear the cached user profile after signing out
      Provider.of<ProfileService>(context, listen: false).clearProfile(); // Call the new method
      debugPrint('Signed out successfully.');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // Example of getting current session, might not be needed if using onAuthStateChange
  Session? get currentSession => _supabase.auth.currentSession;
}