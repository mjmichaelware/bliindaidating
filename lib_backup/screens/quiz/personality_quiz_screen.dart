import 'package:flutter/material.dart';

class PersonalityQuizScreen extends StatefulWidget {
  const PersonalityQuizScreen({super.key});

  @override
  State<PersonalityQuizScreen> createState() => _PersonalityQuizScreenState();
}

class _PersonalityQuizScreenState extends State<PersonalityQuizScreen> {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'You prefer to spend your weekend...',
      'options': ['Reading a book', 'Out with friends', 'Volunteering', 'Exploring nature'],
    },
    {
      'question': 'In a group setting, you tend to be the one who...',
      'options': ['Leads', 'Listens', 'Organizes', 'Challenges'],
    },
    {
      'question': 'What do you value most in a relationship?',
      'options': ['Honesty', 'Adventure', 'Security', 'Independence'],
    },
    {
      'question': 'Which of these appeals to you most?',
      'options': ['Mystery', 'Structure', 'Freedom', 'Connection'],
    },
  ];

  void _nextQuestion(int selectedIndex) {
    setState(() {
      _answers[_currentQuestion] = selectedIndex;
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Quiz Results')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You are a blend of...',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _answers.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retake Quiz'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(title: const Text('Personality Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${_currentQuestion + 1}: ${question['question']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ...List.generate(question['options'].length, (index) {
              final option = question['options'][index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _nextQuestion(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
