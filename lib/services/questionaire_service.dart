import 'package:bliindaidating/models/questionnaire/question.dart'; // Import the new Question model

class QuestionnaireService {
  Future<List<Question>> fetchQuestions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Dummy questions for demonstration. In a real app, these would come from Supabase.
    return [
      Question(
        id: 'q1',
        text: 'What is your ideal type of first date?',
        options: ['Coffee/Drinks', 'Dinner', 'Activity (e.g., hiking, museum)', 'Casual walk in a park'],
        type: 'single_choice',
      ),
      Question(
        id: 'q2',
        text: 'Which of these qualities are most important to you in a partner? (Select all that apply)',
        options: ['Sense of Humor', 'Intelligence', 'Kindness', 'Ambition', 'Creativity', 'Loyalty'],
        type: 'multiple_choice',
      ),
      Question(
        id: 'q3',
        text: 'Describe a perfect lazy Sunday for you.',
        type: 'text_input',
      ),
      Question(
        id: 'q4',
        text: 'How do you typically handle conflict?',
        options: ['Directly and calmly', 'Avoid it if possible', 'Seek compromise', 'Need space to cool off first'],
        type: 'single_choice',
      ),
      Question(
        id: 'q5',
        text: 'What are your top 3 favorite genres of music?',
        type: 'text_input', // Can be comma-separated or handled with a more complex UI
      ),
      Question(
        id: 'q6',
        text: 'Are you a morning person or a night owl?',
        options: ['Morning Person', 'Night Owl', 'Both', 'Neither'],
        type: 'single_choice',
      ),
    ];
  }

  // You would also add methods here for submitting answers to your backend.
  Future<void> submitAnswers(String userId, Map<String, dynamic> answers) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print('Submitting answers for user $userId: $answers');
    // TODO: Implement actual Supabase insertion/update logic here
  }
}