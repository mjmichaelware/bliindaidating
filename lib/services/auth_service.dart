// lib/services/auth_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:supabase_flutter/supabase_flutter.dart';

/// A service class to handle user authentication (login, signup, logout)
/// and provide access to the current authenticated user.
class AuthService extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    // Listen to auth state changes and update _currentUser
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners(); // Notify listeners when auth state changes
      debugPrint('AuthService: Auth state changed. Current user: ${_currentUser?.email}');
    });
    // Initialize current user on startup
    _currentUser = _supabaseClient.auth.currentUser;
    debugPrint('AuthService: Initial user: ${_currentUser?.email}');
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      debugPrint('AuthService: User signed in: ${_currentUser?.email}');
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign in error: ${e.message}');
      rethrow; // Re-throw to be caught by UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      _currentUser = response.user;
      debugPrint('AuthService: User signed up: ${_currentUser?.email}');
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign up error: ${e.message}');
      rethrow; // Re-throw to be caught by UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseClient.auth.signOut();
      _currentUser = null;
      debugPrint('AuthService: User signed out.');
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign out error: ${e.message}');
      rethrow; // Re-throw to be caught by UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to get the current user directly, useful for non-reactive contexts
  User? getCurrentUserSync() {
    return _supabaseClient.auth.currentUser;
  }
}