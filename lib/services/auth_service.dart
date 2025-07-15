// lib/services/auth_service.dart
import 'dart:async'; // <--- ADD THIS IMPORT
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  StreamSubscription<AuthState>? _authStateSubscription;
  final ProfileService _profileService; // Added dependency for ProfileService

  // Constructor now requires ProfileService
  AuthService(this._profileService) {
    // Listen to Supabase authentication state changes
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('AuthService: AuthChangeEvent: $event, Session: ${session?.user?.email}');

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        _currentUser = session?.user;
        if (_currentUser != null) {
          // Immediately fetch or refresh profile when user signs in or session is initial
          // This call will notify ProfileService's listeners, which GoRouter will also listen to
          await _profileService.fetchUserProfile(id: _currentUser!.id);
        }
        notifyListeners(); // Notify AuthService listeners (e.g., any widgets directly watching AuthService)
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _profileService.clearProfile(); // Clear profile data on sign out
        notifyListeners(); // Notify AuthService listeners
      } else if (event == AuthChangeEvent.userUpdated) {
        _currentUser = session?.user;
        if (_currentUser != null) {
          // Re-fetch profile if user details (e.g., email) are updated
          await _profileService.fetchUserProfile(id: _currentUser!.id);
        }
        notifyListeners();
      }
      // You can add other AuthChangeEvent handlers here if needed (e.g., passwordRecovery)
    });

    // Also, fetch initial user and profile state when AuthService is created
    // This handles cases where the app restarts and a session already exists
    _currentUser = _supabase.auth.currentUser;
    if (_currentUser != null) {
      // Don't await here to avoid blocking the constructor; rely on the listener above.
      // The listener will trigger the fetch and notify.
      // If the app is launched and a session already exists, onAuthStateChange.listen
      // will emit AuthChangeEvent.initialSession, triggering the profile fetch.
    }
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Your existing signIn, signUp, signOut methods.
  // The onAuthStateChange listener will handle profile updates and notifications.
  Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      debugPrint('AuthService: Sign In successful for: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign In error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Unexpected sign In error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password);
      debugPrint('AuthService: Sign Up successful for: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign Up error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Unexpected sign Up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('AuthService: Sign Out successful.');
    } on AuthException catch (e) {
      debugPrint('AuthService: Sign Out error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: Unexpected sign out error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}