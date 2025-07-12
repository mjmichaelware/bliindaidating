// lib/services/auth_service.dart

import 'package:flutter/material.dart'; // <--- ADD THIS LINE
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/services/profile_service.dart';

/// A service class to handle user authentication (login, signup, logout)
/// and provide access to the current authenticated user.
class AuthService extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
      debugPrint('AuthService: Auth state changed. Current user: ${_currentUser?.email}');
    });
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
      rethrow;
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
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut({BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseClient.auth.signOut();
      _currentUser = null;
      debugPrint('AuthService: User signed out.');

      if (context != null) {
        Provider.of<ProfileService>(context, listen: false).clearProfile();
      }

    } on AuthException catch (e) {
      debugPrint('AuthService: Sign out error: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  User? getCurrentUserSync() {
    return _supabaseClient.auth.currentUser;
  }
}