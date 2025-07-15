// lib/screens/daily/daily_prompts_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:bliindaidating/shared/glowing_button.dart';
import 'package:bliindaidating/services/ai_logic_service.dart'; // Import AiLogicService
import 'package:bliindaidating/app_constants.dart'; // For colors and spacing
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this

class DailyPromptsScreen extends StatefulWidget {
  const DailyPromptsScreen({super.key});

  @override
  State<DailyPromptsScreen> createState() => _DailyPromptsScreenState();
}

class _DailyPromptsScreenState extends State<DailyPromptsScreen> {
  String? _currentDailyPrompt; // Now holds the fetched prompt
  bool _isLoadingPrompt = true;
  String? _error;

  // You can keep local answers if you want to store them temporarily on the client
  // before submitting to a backend questionnaire system.
  final Map<int, String> answers = {};
  final TextEditingController _controller = TextEditingController();
  int _currentPromptIndex = 0; // Still used for local answer tracking, if needed

  @override
  void initState() {
    super.initState();
    _fetchDailyPrompt(); // Fetch a prompt when the screen initializes
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchDailyPrompt() async {
    setState(() {
      _isLoadingPrompt = true;
      _error = null;
    });
    try {
      final aiService = Provider.of<AiLogicService>(context, listen: false);
      // You can pass context if your backend uses it, e.g., user's location, interests
      final prompt = await aiService.generateDailyPrompt(context: 'dating app user, self-reflection');
      setState(() {
        _currentDailyPrompt = prompt;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load daily prompt: $e';
        debugPrint('Error fetching daily prompt: $e');
      });
    } finally {
      setState(() {
        _isLoadingPrompt = false;
      });
    }
  }

  void _submitAnswer() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      // This part remains for local answer storage, if you need it.
      // For actual questionnaire integration, you'd send this to QuestionnaireService.
      answers[_currentPromptIndex] = _controller.text.trim();
      _controller.clear();
      // If you have multiple AI prompts, you'd fetch a new one here.
      // For now, it just cycles locally or fetches a new one.
      _fetchDailyPrompt(); // Fetch a new prompt after submitting an answer
    });
    // TODO: Integrate with QuestionnaireService.submitAnswers if this is part of a persistent questionnaire
  }

  @override
  Widget build(BuildContext
  context) {
    final theme = Theme.of(context);

    String? previousAnswer = answers[_currentPromptIndex]; // For local display

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Prompts'),
        backgroundColor: AppConstants.primaryColorShade900, // Using AppConstants colors
        foregroundColor: AppConstants.textColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingPrompt ? null : _fetchDailyPrompt,
            tooltip: 'Get New Daily Prompt',
          ),
        ],
      ),
      backgroundColor: AppConstants.backgroundColor, // Using AppConstants colors
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: _isLoadingPrompt
              ? const Center(child: LoadingIndicatorWidget())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: theme.textTheme.titleMedium?.copyWith(color: AppConstants.errorColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          ElevatedButton(
                            onPressed: _fetchDailyPrompt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              foregroundColor: AppConstants.textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : _currentDailyPrompt == null || _currentDailyPrompt!.isEmpty
                      ? Center(
                          child: EmptyStateWidget(
                            message: 'No daily prompt available. Please try again!',
                            onRefresh: _fetchDailyPrompt,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Prompt',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppConstants.textHighEmphasis,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            Text(
                              _currentDailyPrompt!,
                              style: theme.textTheme.titleMedium?.copyWith(color: AppConstants.textMediumEmphasis),
                            ),
                            const SizedBox(height: AppConstants.spacingLarge),
                            TextField(
                              controller: _controller,
                              maxLines: 4,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppConstants.cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'Write your answer here...',
                                hintStyle: TextStyle(color: AppConstants.textLowEmphasis),
                                contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
                              ),
                              style: TextStyle(color: AppConstants.textColor),
                            ),
                            const SizedBox(height: AppConstants.spacingLarge),
                            Row(
                              children: [
                                GlowingButton(
                                  icon: Icons.send_rounded,
                                  text: 'Submit Answer',
                                  onPressed: _submitAnswer,
                                  gradientColors: const [
                                    AppConstants.tertiaryColor, // Using AppConstants colors
                                    AppConstants.primaryColorShade700,
                                  ],
                                  height: 48,
                                  width: 160,
                                  textStyle: const TextStyle(fontSize: AppConstants.fontSizeMedium, color: AppConstants.textColor),
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                if (previousAnswer != null)
                                  Expanded(
                                    child: Text(
                                      'Previous answer:\n$previousAnswer',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: AppConstants.textLowEmphasis),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
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