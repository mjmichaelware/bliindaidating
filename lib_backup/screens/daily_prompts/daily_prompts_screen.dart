import 'package:flutter/material.dart';

class DailyPromptsScreen extends StatefulWidget {
  const DailyPromptsScreen({super.key});

  @override
  State<DailyPromptsScreen> createState() => _DailyPromptsScreenState();
}

class _DailyPromptsScreenState extends State<DailyPromptsScreen> {
  final List<String> _prompts = [
    'What is your perfect day like?',
    'What is a dream you have yet to accomplish?',
    'Describe a book or movie that changed your perspective.',
    'What’s a hobby you wish you had more time for?',
    'What’s something kind you did recently?',
  ];

  final Map<int, String> _responses = {};
  int _currentPromptIndex = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitResponse() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _responses[_currentPromptIndex] = _controller.text.trim();
      _controller.clear();
      if (_currentPromptIndex < _prompts.length - 1) {
        _currentPromptIndex++;
      } else {
        _showThankYouDialog();
      }
    });
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank you!'),
        content: const Text('Your responses have been saved.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[_currentPromptIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Prompt')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prompt ${_currentPromptIndex + 1} of ${_prompts.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              prompt,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your response here...',
                filled: true,
                fillColor: Colors.deepPurple.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitResponse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Response', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
