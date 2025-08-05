// lib/services/newsfeed_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bliindaidating/models/newsfeed/newsfeed_item.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';

class NewsfeedService extends ChangeNotifier {
  AiLogicService _aiLogicService = AiLogicService();

  NewsfeedService({AiLogicService? aiLogicService})
      : _aiLogicService = aiLogicService ?? AiLogicService();

  List<NewsfeedItem> _newsfeedItems = [];
  List<NewsfeedItem> get newsfeedItems => _newsfeedItems;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refreshNewsfeed(
    String userProfileSummary,
    List<Map<String, dynamic>> recentActivity,
    String jwtToken,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final List<Map<String, dynamic>>? rawNewsfeedItems = await _aiLogicService.generateNewsFeed(
        userProfileSummary,
        recentActivity,
        jwtToken,
      );

      if (rawNewsfeedItems == null) {
        _newsfeedItems = [];
        throw Exception('Failed to get newsfeed items from AI service.');
      }
      
      // Map the raw data to NewsfeedItem objects
      _newsfeedItems = rawNewsfeedItems.map((item) => NewsfeedItem.fromJson(item)).toList();
      debugPrint('NewsfeedService: News feed items generated successfully (${_newsfeedItems.length} items).');

    } on SocketException {
      _errorMessage = 'No internet connection. Please check your network settings.';
      _newsfeedItems = [];
    } on HttpException {
      _errorMessage = "Couldn't find the requested data.";
      _newsfeedItems = [];
    } catch (e) {
      _errorMessage = 'Failed to refresh newsfeed: $e';
      _newsfeedItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}