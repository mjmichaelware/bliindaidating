import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
// lib/services/newsfeed_service.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';
import 'package:bliindaidating/services/ai_logic_service.dart'; // FIX: This import was missing or incorrect

class NewsfeedService extends ChangeNotifier {
  final AiLogicService _aiLogicService;

  NewsfeedService(this._aiLogicService);

  Future<List<String>> refreshNewsfeed(
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

      return newsfeedItems;
    } on SocketException {
      debugPrint('No internet connection. Please check your network settings.');
      rethrow;
    } on HttpException {
      debugPrint("Couldn't find the requested data.");
      rethrow;
    } catch (e) {
      debugPrint('Failed to refresh newsfeed: $e');
      rethrow;
    }
  }
}