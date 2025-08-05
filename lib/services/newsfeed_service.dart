import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';

class NewsfeedService extends ChangeNotifier {
  AiLogicService _aiLogicService; // FIX: Changed to non-final to allow updates

  // FIX: Corrected constructor to use a named argument
  NewsfeedService({required AiLogicService aiLogicService})
      : _aiLogicService = aiLogicService;

  List<String> _newsfeedItems = ['Loading news feed...'];
  List<String> get newsfeedItems => _newsfeedItems;

  // FIX: Added the missing method to allow ChangeNotifierProxyProvider to update the service
  void updateAiLogicService(AiLogicService newAiLogicService) {
    if (_aiLogicService != newAiLogicService) {
      _aiLogicService = newAiLogicService;
      debugPrint('NewsfeedService: AiLogicService updated.');
    }
  }

  Future<void> refreshNewsfeed(
    String userProfileSummary,
    List<Map<String, dynamic>> recentActivity,
    String jwtToken,
  ) async {
    try {
      final List<String>? newsfeedItems = await _aiLogicService.generateNewsFeed(
        userProfileSummary,
        recentActivity,
        jwtToken,
      );

      if (newsfeedItems == null) {
        throw Exception('Failed to get newsfeed items from AI service.');
      }

      _newsfeedItems = newsfeedItems;
      notifyListeners();
    } on SocketException {
      debugPrint('No internet connection. Please check your network settings.');
      _newsfeedItems = ['No internet connection.'];
      notifyListeners();
      rethrow;
    } on HttpException {
      debugPrint("Couldn't find the requested data.");
      _newsfeedItems = ['Failed to get data from the server.'];
      notifyListeners();
      rethrow;
    } catch (e) {
      debugPrint('Failed to refresh newsfeed: $e');
      _newsfeedItems = ['Failed to refresh newsfeed.'];
      notifyListeners();
      rethrow;
    }
  }
}