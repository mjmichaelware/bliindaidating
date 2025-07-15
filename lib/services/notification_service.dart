// lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:bliindaidating/app_constants.dart';
// import 'package:bliindaidating/models/notification_item.dart'; // Assuming you might have a NotificationItem model

class NotificationService {
  final String _baseUrl = AppConstants.baseUrl;

  /// Fetches a list of dummy notifications from the backend.
  /// This assumes a new backend endpoint like /generate-dummy-notifications/
  Future<List<String>> fetchDummyNotifications({int count = 5}) async {
    final url = Uri.parse('$_baseUrl/generate-dummy-notifications/?count=$count'); // Assuming a GET endpoint

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['notifications'] is List) {
          // Assuming backend returns {'notifications': ['Notif 1', 'Notif 2']}
          return List<String>.from(data['notifications']);
        }
        debugPrint('Backend returned unexpected format for /generate-dummy-notifications: ${response.body}');
        return [];
      } else {
        debugPrint('Failed to fetch dummy notifications: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching dummy notifications: $e');
      return [];
    }
  }

  // You might also add methods here to fetch real notifications from Supabase
  // if you implement a notification persistence system.
  // Future<List<NotificationItem>> fetchUserNotifications(String userId) async { ... }
}