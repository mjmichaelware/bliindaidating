import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';

class DailyPromptsScreen extends StatefulWidget {
  const DailyPromptsScreen({super.key});

  @override
  State<DailyPromptsScreen> createState() => _DailyPromptsScreenState();
}

class _DailyPromptsScreenState extends State<DailyPromptsScreen> {
  final List<String> prompts = [
    'What does your perfect day look like?',
    'Describe a dream you want to accomplish.',
    'What is your favorite way to relax?',
    'What qualities do you value most in friends?',
    'Share a fun fact about yourself.',
    'What’s your go-to comfort food?',
    'If you could travel anywhere, where would you go?',
  ];

  final Map<int, String> answers = {};

  final TextEditingController _controller = TextEditingController();

  int _currentPromptIndex = 0;

  void _submitAnswer() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      answers[_currentPromptIndex] = _controller.text.trim();
      _controller.clear();
      _currentPromptIndex = (_currentPromptIndex + 1) % prompts.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String currentPrompt = prompts[_currentPromptIndex];
    String? previousAnswer = answers[_currentPromptIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Prompts'),
        backgroundColor: Colors.deepPurple.shade900,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Prompt',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                currentPrompt,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.deepPurple.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Write your answer here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  GlowingButton(
                    icon: Icons.send_rounded,
                    text: 'Submit Answer',
                    onPressed: _submitAnswer,
                    gradientColors: const [
                      Color(0xFF8E24AA),
                      Color(0xFFD32F2F),
                    ],
                    height: 48,
                    width: 160,
                    textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  ),

                  const SizedBox(width: 16),

                  if (previousAnswer != null)
                    Expanded(
                      child: Text(
                        'Previous answer:\n$previousAnswer',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
