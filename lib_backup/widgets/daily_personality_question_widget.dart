import 'package:flutter/material.dart';

class DailyPersonalityQuestionWidget extends StatefulWidget {
  const DailyPersonalityQuestionWidget({super.key});

  @override
  State<DailyPersonalityQuestionWidget> createState() => _DailyPersonalityQuestionWidgetState();
}

class _DailyPersonalityQuestionWidgetState extends State<DailyPersonalityQuestionWidget> {
  // Example questions. In real app, load from service or API
  final List<String> _questions = [
    'What motivates you to get out of bed every morning?',
    'Describe a perfect day for you.',
    'What do you value most in a friendship?',
    'How do you handle stressful situations?',
    'If you could master any skill instantly, what would it be?',
  ];

  int _currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _answerSubmitted = false;

  void _submitAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    setState(() {
      _answerSubmitted = true;
    });

    // TODO: Save answer to backend or local storage
  }

  void _nextQuestion() {
    setState(() {
      _answerSubmitted = false;
      _answerController.clear();
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.7),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Personality Question',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.redAccent,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            question,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          if (!_answerSubmitted) ...[
            TextField(
              controller: _answerController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.red.shade400,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.deepPurple.shade800,
                hintText: 'Write your answer here...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitAnswer(),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                  shadowColor: Colors.red.shade900,
                  minimumSize: const Size(120, 44),
                ),
                child: const Text('Submit'),
              ),
            ),
          ] else ...[
            // After submission, show confirmation and next question button
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: Colors.greenAccent.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Answer saved!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.greenAccent.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      minimumSize: const Size(140, 44),
                    ),
                    child: const Text('Next Question'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
