// lib/services/profile_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:bliindaidating/models/user_profile.dart';

class ProfileService {
  // Correctly access the Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required DateTime dateOfBirth,
    required String gender,
    String? bio,
    String? profilePictureUrl,
  }) async {
    try {
      final response = await _supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'bio': bio,
        'profile_picture_url': profilePictureUrl,
      });
      // Supabase 2.x.x changed how errors are returned; they are part of the response object
      if (response.error != null) {
        debugPrint('ProfileService createUserProfile error: ${response.error!.message}');
        throw Exception(response.error!.message);
      }
      debugPrint('User profile created successfully for $userId');
    } catch (e) {
      debugPrint('ProfileService unexpected createUserProfile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePictureUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (fullName != null) updates['full_name'] = fullName;
      if (dateOfBirth != null) updates['date_of_birth'] = dateOfBirth.toIso8601String();
      if (gender != null) updates['gender'] = gender;
      if (bio != null) updates['bio'] = bio;
      if (profilePictureUrl != null) updates['profile_picture_url'] = profilePictureUrl;

      final response = await _supabase.from('profiles').update(updates).eq('id', userId);

      if (response.error != null) {
        debugPrint('ProfileService updateUserProfile error: ${response.error!.message}');
        throw Exception(response.error!.message);
      }
      debugPrint('User profile updated successfully for $userId');
    } catch (e) {
      debugPrint('ProfileService unexpected updateUserProfile error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // For select().eq().single(), the data is directly in .data if successful, .error if not found or error
      final response = await _supabase.from('profiles').select().eq('id', userId).single();
      if (response.error != null) {
        debugPrint('ProfileService getUserProfile error: ${response.error!.message}');
        return null;
      }
      if (response.data != null) {
        return UserProfile.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('ProfileService unexpected getUserProfile error: $e');
      return null;
    }
  }

  Future<void> saveUserInterests(String userId, List<String> interests) async {
    await _supabase.from('user_interests').delete().eq('user_id', userId);

    final List<Map<String, dynamic>> inserts = interests
        .map((interest) => {'user_id': userId, 'interest': interest})
        .toList();

    if (inserts.isNotEmpty) {
      final response = await _supabase.from('user_interests').insert(inserts);
      if (response.error != null) {
        debugPrint('ProfileService saveUserInterests error: ${response.error!.message}');
        throw Exception(response.error!.message);
      }
    }
    debugPrint('User interests saved for $userId');
  }

  Future<void> saveUserAvailability(String userId, Map<String, List<String>> availability) async {
    await _supabase.from('user_availability').delete().eq('user_id', userId);

    final List<Map<String, dynamic>> inserts = [];
    availability.forEach((day, timeSlots) {
      inserts.add({
        'user_id': userId,
        'day_of_week': day,
        'time_slots': timeSlots,
      });
    });

    if (inserts.isNotEmpty) {
      final response = await _supabase.from('user_availability').insert(inserts);
      if (response.error != null) {
        debugPrint('ProfileService saveUserAvailability error: ${response.error!.message}');
        throw Exception(response.error!.message);
      }
    }
    debugPrint('User availability saved for $userId');
  }

  Future<void> saveUserIntentions(String userId, List<String> intentions) async {
    await _supabase.from('user_intentions').delete().eq('user_id', userId);

    final List<Map<String, dynamic>> inserts = intentions
        .map((intention) => {'user_id': userId, 'intention': intention})
        .toList();

    if (inserts.isNotEmpty) {
      final response = await _supabase.from('user_intentions').insert(inserts);
      if (response.error != null) {
        debugPrint('ProfileService saveUserIntentions error: ${response.error!.message}');
        throw Exception(response.error!.message);
      }
    }
    debugPrint('User intentions saved for $userId');
  }
}