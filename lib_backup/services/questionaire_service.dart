import 'package:bliindaidating/models/questionnaire/question.dart';
import 'package:bliindaidating/data/dummy_data.dart'; // Import dummy data

class QuestionnaireService {
  Future<List<Question>> fetchQuestions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 5)); // Increased delay to simulate AI generation time

    // Return hardcoded dummy questions
    return dummyQuestionnaireQuestions;
  }

  // You would also add methods here for submitting answers to your backend.
  Future<void> submitAnswers(String id, Map<String, dynamic> answers) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print('Submitting answers for user $id: $answers');
    // TODO: Implement actual Supabase insertion/update logic here
  }
}