// lib/utils/supabase_config.dart
import 'package:flutter/foundation.dart'; // Required for kReleaseMode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading .env file in development
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    // Load .env file for local development.
    // In production (web/mobile builds), environment variables are passed via --dart-define.
    if (kDebugMode) { // Only load .env in debug mode
      await dotenv.load(fileName: ".env");
    }

    // Retrieve Supabase URL and Anon Key.
    // In debug mode, prioritize .env. In release mode, rely solely on --dart-define.
    // This allows local dev with `.env` and secure production builds with `--dart-define`.

    // PRODUCTION/RELEASE URL & KEY: Must be passed via --dart-define during build
    // Example build command:
    // flutter build web \
    //   --dart-define=SUPABASE_URL="https://kynzpohycwdphorxsnzy.supabase.co" \
    //   --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI..." \
    //   --release

    final String supabaseUrl = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_URL')
        : dotenv.env['SUPABASE_URL'] ?? 'http://localhost:54321'; // Default local if .env is missing
    final String supabaseAnonKey = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_ANON_KEY')
        : dotenv.env['SUPABASE_KEY'] ?? 'YOUR_LOCAL_DEBUG_ANON_KEY'; // Use SUPABASE_KEY from your .env for local

    // Basic validation for critical keys
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty ||
        (supabaseUrl == 'http://localhost:54321' && kReleaseMode) || // Warn if local URL is used in release
        (supabaseAnonKey == 'YOUR_LOCAL_DEBUG_ANON_KEY' && kReleaseMode)) { // Warn if local key is used in release
      debugPrint('🚨 SupabaseConfig Warning: Supabase URL or Anon Key might be missing or set to debug defaults in RELEASE mode.');
      debugPrint('Please ensure --dart-define flags are used for production builds.');
      debugPrint('Current URL: $supabaseUrl');
      debugPrint('Current Key: ${supabaseAnonKey.substring(0, 10)}...'); // Mask key for security
      throw Exception('Supabase credentials not properly configured for the current build environment.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.pkce, // Recommended for enhanced security
      debug: kDebugMode, // Enable Supabase debugging in debug mode
    );
  }
}