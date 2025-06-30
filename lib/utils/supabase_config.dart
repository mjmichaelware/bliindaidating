// lib/utils/supabase_config.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://kynzpohycwdphorxsnzy.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5bnpwb2h5Y3dkcGhvcnhzbnp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMTAyNjIsImV4cCI6MjA2Njg4NjI2Mn0.W8ZRG8ZXL07PS6-n6H4cQtqLlChkUq3ydhcqmko9tZU';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
