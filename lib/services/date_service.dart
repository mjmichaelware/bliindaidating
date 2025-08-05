import 'package:flutter/foundation.dart';
import 'package:bliindaidating/services/ai_logic_service.dart';

/// A service to manage user's scheduled dates.
class DateService extends ChangeNotifier {
  final AiLogicService _aiLogicService;

  DateService(this._aiLogicService);

  List<Map<String, dynamic>> _dates = [];
  List<Map<String, dynamic>> get dates => _dates;

  // Placeholder for user profile data (should be fetched from a user service)
  final String _userProfileSummary = "A 25-year-old software engineer who enjoys hiking and playing guitar.";

  Future<void> refreshDates(String jwtToken) async {
    debugPrint('DateService: Attempting to fetch dates...');
    try {
      final List<Map<String, dynamic>>? fetchedDates = await _aiLogicService.getAiGeneratedDates(_userProfileSummary, jwtToken);

      if (fetchedDates != null) {
        _dates = fetchedDates;
      } else {
        _dates = [];
      }
      debugPrint('DateService: Fetched ${_dates.length} dates.');
      notifyListeners();
    } catch (e) {
      debugPrint('DateService: Failed to refresh dates: $e');
      _dates = [];
      notifyListeners();
      rethrow;
    }
  }
}
