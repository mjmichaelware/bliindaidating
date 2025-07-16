// lib/services/questionnaire_service.dart

import 'package:flutter/foundation.dart'; // For ChangeNotifier and debugPrint
import 'package:bliindaidating/models/questionnaire/question.dart'; // Import the Question model
import 'dart:convert'; // For jsonEncode, jsonDecode
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:bliindaidating/app_constants.dart'; // Import AppConstants for Gemini API Key

/// A service to manage questionnaire data and progress, including AI suggestions.
class QuestionnaireService extends ChangeNotifier {
  // Example: Track progress of a questionnaire
  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  int _totalQuestions = 0; // Will be set after fetching questions
  int get totalQuestions => _totalQuestions;
  set totalQuestions(int value) {
    _totalQuestions = value;
    notifyListeners();
  }

  List<Question> _questions = [];
  List<Question> get questions => _questions;

  QuestionnaireService() {
    debugPrint('QuestionnaireService: Initialized.');
    // Questions will be fetched by the screen, or you can uncomment below
    // _fetchQuestions();
  }

  Future<List<Question>> fetchQuestions() async {
    debugPrint('QuestionnaireService: Fetching questions...');
    // In a real app, you would fetch these from your backend/Supabase
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    _questions = [
      Question(id: 'q1', text: 'What is your ideal first date?', type: QuestionType.text),
      Question(id: 'q2', text: 'What are your top 3 hobbies?', type: QuestionType.text),
      Question(id: 'q3', text: 'How do you define success?', type: QuestionType.text),
      Question(id: 'q4', text: 'What is your favorite way to relax?', type: QuestionType.text),
      Question(id: 'q5', text: 'Describe your ideal partner in 3 words.', type: QuestionType.text),
      Question(id: 'q6', text: 'What is a skill you\'d like to learn?', type: QuestionType.text),
      Question(id: 'q7', text: 'What\'s your favorite travel destination?', type: QuestionType.text),
      Question(id: 'q8', text: 'What are you passionate about?', type: QuestionType.text),
      Question(id: 'q9', text: 'How do you handle disagreements?', type: QuestionType.text),
      Question(id: 'q10', text: 'What\'s one thing that always makes you smile?', type: QuestionType.text),
    ];
    _totalQuestions = _questions.length;
    notifyListeners();
    debugPrint('QuestionnaireService: Fetched ${_questions.length} questions.');
    return _questions;
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      debugPrint('QuestionnaireService: Moved to question index $_currentQuestionIndex');
    } else {
      debugPrint('QuestionnaireService: Questionnaire complete (logic for submission will follow)!');
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
      debugPrint('QuestionnaireService: Moved to question index $_currentQuestionIndex');
    }
  }

  /// Generates an AI-suggested answer for a given question and user context.
  Future<String> getAiSuggestedAnswer(String questionText, String userContext) async {
    debugPrint('QuestionnaireService: Getting AI suggested answer for "$questionText" with context "$userContext"');
    try {
      final prompt = """
      Given the following question and user context, provide a concise and helpful suggested answer.
      Keep the answer to 1-2 sentences. Do not include any introductory phrases like "Suggested answer:".
      
      Question: "$questionText"
      User Context: "$userContext"
      
      Example:
      Question: "What is your ideal first date?"
      User Context: "I love nature and quiet evenings."
      Suggested Answer: "A relaxed picnic in a beautiful park, followed by a quiet walk as the sun sets."
      
      Now, provide the suggested answer for the given question and context:
      """;

      // Use the provided fetch call structure for LLM interaction
      final apiKey = AppConstants.geminiApiKey; // Access API key from AppConstants
      const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=";

      final http.Response response = await http.post(
        Uri.parse('$apiUrl$apiKey'), // Concatenate API URL with the key
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': prompt}]}
          ]
        }),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['candidates'] != null && result['candidates'].isNotEmpty &&
          result['candidates'][0]['content'] != null && result['candidates'][0]['content']['parts'] != null &&
          result['candidates'][0]['content']['parts'].isNotEmpty) {
        final String text = result['candidates'][0]['content']['parts'][0]['text'];
        debugPrint('AI Suggested Answer Raw Response: $text');
        return text.trim(); // Return the trimmed text
      } else {
        debugPrint('AI Suggested Answer LLM response was empty or malformed or bad status: ${response.statusCode}');
        return 'No suggestion available.';
      }
    } catch (e) {
      debugPrint('Error calling LLM for AI suggested answer: $e');
      return 'Could not generate suggestion.';
    }
  }

  /// Submits the questionnaire answers to the backend.
  Future<void> submitAnswers(String userId, Map<String, dynamic> answers) async {
    debugPrint('QuestionnaireService: Submitting answers for user $userId: $answers');
    // In a real app, you would send this to your backend/Supabase
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    debugPrint('QuestionnaireService: Answers submitted successfully.');
    // You might update ProfileService here to mark phase 2 complete
  }
}