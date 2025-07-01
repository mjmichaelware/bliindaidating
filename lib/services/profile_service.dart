import '../utils/superbase_config.dart';

class ProfileService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<void> createOrUpdateProfile({
    required String userId,
    required String fullName,
    String? avatarUrl,
  }) async {
    final data = {
      'id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _client
        .from('profiles')
        .upsert(data, onConflict: ['id'])
        .execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single()
        .execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
    return response.data;
  }
}
