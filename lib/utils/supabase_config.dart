// lib/utils/supabase_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    if (kDebugMode) {
      await dotenv.load(fileName: ".env");
    }

    final String supabaseUrl = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_URL')
        : dotenv.env['SUPABASE_URL'] ?? 'http://localhost:54321';
    final String supabaseAnonKey = kReleaseMode
        ? const String.fromEnvironment('SUPABASE_ANON_KEY')
        : dotenv.env['SUPABASE_KEY'] ?? 'YOUR_LOCAL_DEBUG_ANON_KEY';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty ||
        (supabaseUrl == 'http://localhost:54321' && kReleaseMode) ||
        (supabaseAnonKey == 'YOUR_LOCAL_DEBUG_ANON_KEY' && kReleaseMode)) {
      debugPrint('🚨 SupabaseConfig Warning: Supabase URL or Anon Key might be missing or set to debug defaults in RELEASE mode.');
      debugPrint('Please ensure --dart-define flags are used for production builds.');
      debugPrint('Current URL: $supabaseUrl');
      debugPrint('Current Key: ${supabaseAnonKey.substring(0, 10)}...');
      throw Exception('Supabase credentials not properly configured for the current build environment.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // REMOVED: authFlowType: AuthFlowType.pkce, // This parameter is no longer valid in supabase_flutter 2.9.1
      debug: kDebugMode,
    );
  }
}