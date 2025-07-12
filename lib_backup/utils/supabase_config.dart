// lib/utils/supabase_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    if (kDebugMode) {
      await dotenv.load(fileName: ".env");
    }

    // Determine Supabase URL based on build mode
    final String supabaseUrl = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_URL')
        : dotenv.env['SUPABASE_URL'] ?? 'http://localhost:54321';

    // Determine Supabase Anon Key based on build mode
    // FIXED: Changed 'SUPABASE_ANON_KEY' to 'SUPABASE_KEY' for kReleaseMode consistency
    final String supabaseAnonKey = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_KEY') // Use SUPABASE_KEY for release builds
        : dotenv.env['SUPABASE_KEY'] ?? 'YOUR_LOCAL_DEBUG_SUPABASE_KEY'; // Use SUPABASE_KEY for debug builds

    if ((supabaseUrl ?? []).isEmpty || (supabaseAnonKey ?? []).isEmpty ||
        (supabaseUrl == 'http://localhost:54321' && kReleaseMode) ||
        (supabaseAnonKey == 'YOUR_LOCAL_DEBUG_SUPABASE_KEY' && kReleaseMode)) { // Also check the default for new key name
      debugPrint('🚨 SupabaseConfig Warning: Supabase URL or Anon Key might be missing or set to debug defaults in RELEASE mode.');
      debugPrint('Please ensure --dart-define flags are used for production builds.');
      debugPrint('Current URL: $supabaseUrl');
      debugPrint('Current Key: ${(supabaseAnonKey ?? []).isNotEmpty ? supabaseAnonKey.substring(0, 10) : 'EMPTY'}...');
      throw Exception('Supabase credentials not properly configured for the current build environment.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
}