// lib/services/questionaire_service.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:bliindaidating/models/questionnaire/question.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data
import 'package:bliindaidating/services/ai_logic_service.dart'; // Import AiLogicService

class QuestionnaireService {
  final AiLogicService _aiLogicService;

  QuestionnaireService({AiLogicService? aiLogicService})
      : _aiLogicService = aiLogicService ?? AiLogicService(); // Initialize AiLogicService

  Future<List<Question>> fetchQuestions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1)); // Reduced delay for better UX during testing

    // Return hardcoded dummy questions
    return dummyQuestionnaireQuestions;
  }

  /// Submits answers to the backend (or local storage for now).
  /// This method will be expanded to interact with Supabase for persistence.
  Future<void> submitAnswers(String userId, Map<String, dynamic> answers) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Submitting answers for user $userId: $answers');
    // TODO: Implement actual Supabase insertion/update logic here for questionnaire answers
    // This will likely involve updating the 'questionnaire_answers' JSONB field
    // in the user_profiles table via ProfileService or directly.
  }

  /// NEW: Requests an AI-generated answer for a given question.
  /// userContext: A map containing relevant user data to help the AI generate a personalized answer.
  Future<String?> getAiSuggestedAnswer(String questionText, Map<String, dynamic> userContext) async {
    try {
      debugPrint('Requesting AI suggested answer for question: $questionText');
      final answer = await _aiLogicService.generateQuestionnaireAnswer(questionText, userContext);
      if (answer != null) {
        debugPrint('AI suggested answer received: $answer');
      } else {
        debugPrint('AI did not return a suggested answer.');
      }
      return answer;
    } catch (e) {
      debugPrint('Error getting AI suggested answer: $e');
      return null;
    }
  }
}