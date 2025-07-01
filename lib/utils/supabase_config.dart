// lib/utils/supabase_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    if (kDebugMode) {
      // Load .env file only in debug mode.
      // In release mode, --dart-define flags are expected.
      await dotenv.load(fileName: ".env");
    }

    final String supabaseUrl = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_URL')
        : dotenv.env['SUPABASE_URL'] ?? 'http://localhost:54321';

    // IMPORTANT: Using 'SUPABASE_KEY' here to match your provided .env file content.
    // If your .env file changes to 'SUPABASE_ANON_KEY', this line must be updated.
    final String supabaseAnonKey = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_ANON_KEY')
        : dotenv.env['SUPABASE_KEY'] ?? 'YOUR_LOCAL_DEBUG_ANON_KEY';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty ||
        (supabaseUrl == 'http://localhost:54321' && kReleaseMode) ||
        (supabaseAnonKey == 'YOUR_LOCAL_DEBUG_ANON_KEY' && kReleaseMode)) {
      debugPrint('🚨 SupabaseConfig Warning: Supabase URL or Anon Key might be missing or set to debug defaults in RELEASE mode.');
      debugPrint('Please ensure --dart-define flags are used for production builds.');
      debugPrint('Current URL: $supabaseUrl');
      // FIX: Conditionally print substring to prevent RangeError if key is empty
      debugPrint('Current Key: ${supabaseAnonKey.isNotEmpty ? supabaseAnonKey.substring(0, 10) : 'EMPTY'}...');
      throw Exception('Supabase credentials not properly configured for the current build environment.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
    );
  }
}