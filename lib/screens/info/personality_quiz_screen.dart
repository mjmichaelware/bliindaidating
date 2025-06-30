import 'package:flutter/material.dart';
import 'package:bliindaidating/shared/glowing_button.dart';

class PersonalityQuizScreen extends StatefulWidget {
  const PersonalityQuizScreen({super.key});

  @override
  State<PersonalityQuizScreen> createState() => _PersonalityQuizScreenState();
}

class _PersonalityQuizScreenState extends State<PersonalityQuizScreen> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'You prefer to spend time:',
      'options': ['Alone', 'With a few close friends', 'At large social events', 'Doing something creative'],
    },
    {
      'question': 'When making decisions, you tend to:',
      'options': ['Follow your head', 'Follow your heart', 'Seek advice', 'Go with the flow'],
    },
    {
      'question': 'In stressful situations, you:',
      'options': ['Withdraw and reflect', 'Talk to someone', 'Take action immediately', 'Try to find humor'],
    },
    {
      'question': 'Your ideal weekend involves:',
      'options': ['Reading or learning', 'Outdoor adventure', 'Relaxing at home', 'Trying new experiences'],
    },
    {
      'question': 'How do you handle conflicts?',
      'options': ['Avoid them', 'Address directly', 'Seek compromise', 'Ignore and move on'],
    },
  ];

  final Map<int, int> answers = {}; // questionIndex -> selectedOptionIndex

  void selectAnswer(int questionIndex, int optionIndex) {
    setState(() {
      answers[questionIndex] = optionIndex;
    });
  }

  String getResult() {
    // Simple mock personality assessment based on most frequent answer
    if (answers.isEmpty) return 'No result yet';

    Map<int, int> counts = {};
    for (var val in answers.values) {
      counts[val] = (counts[val] ?? 0) + 1;
    }
    int maxIndex = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Map index to personality type (mock)
    switch (maxIndex) {
      case 0:
        return 'Introvert';
      case 1:
        return 'Empath';
      case 2:
        return 'Leader';
      case 3:
        return 'Explorer';
      default:
        return 'Unique';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personality Quiz'),
        backgroundColor: Colors.deepPurple.shade900,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final selected = answers[index];

                    return Card(
                      color: Colors.deepPurple.shade800.withAlpha(220),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question['question'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              question['options'].length,
                              (optIndex) {
                                final option = question['options'][optIndex];
                                final isSelected = selected == optIndex;
                                return ListTile(
                                  title: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected ? Colors.pink.shade300 : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  leading: Radio<int>(
                                    value: optIndex,
                                    groupValue: selected,
                                    activeColor: Colors.pink.shade300,
                                    onChanged: (val) => selectAnswer(index, val!),
                                  ),
                                  onTap: () => selectAnswer(index, optIndex),
                                  contentPadding: EdgeInsets.zero,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Your Personality Type:',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),

              Text(
                getResult(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.pink.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              GlowingButton(
                icon: Icons.refresh_rounded,
                text: 'Reset Quiz',
                onPressed: () {
                  setState(() {
                    answers.clear();
                  });
                },
                gradientColors: const [
                  Color(0xFF8E24AA),
                  Color(0xFFD32F2F),
                ],
                height: 48,
                width: 160,
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
