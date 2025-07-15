// lib/screens/questionnaire/questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/questionnaire_service.dart'; // Corrected import
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart';
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // FIXED: Added import for EmptyStateWidget
import 'package:bliindaidating/widgets/questionnaire/answer_input_field.dart';
import 'package:bliindaidating/widgets/questionnaire/question_card.dart'; // FIXED: Added import for QuestionCard
import 'package:bliindaidating/widgets/questionnaire/question_progress_indicator.dart'; // FIXED: Added import for QuestionProgressIndicator
import 'package:bliindaidating/models/questionnaire/question.dart'; // Import the Question model
import 'package:go_router/go_router.dart'; // For navigation
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for currentUser.userId

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _answerController = TextEditingController();
  List<Question> _questions = []; // Will be fetched from service
  bool _isLoadingQuestions = true;
  String? _questionsError;

  Map<String, String> _answers = {}; // Store answers by question ID

  @override
  void initState() {
    super.initState();
    _fetchQuestionsAndInitialize();
  }

  Future<void> _fetchQuestionsAndInitialize() async {
    setState(() {
      _isLoadingQuestions = true;
      _questionsError = null;
    });
    try {
      final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
      final fetchedQuestions = await questionnaireService.fetchQuestions();
      setState(() {
        _questions = fetchedQuestions;
        questionnaireService.totalQuestions = _questions.length; // Set total questions
      });
    } catch (e) {
      setState(() {
        _questionsError = 'Failed to load questions: $e';
        debugPrint('Error fetching questions: $e');
      });
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    if (_pageController.page!.toInt() < _questions.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeOut,
      );
      questionnaireService.nextQuestion();
      // Populate answer for the *new* current question if it exists
      final nextQuestionId = _questions[_pageController.page!.toInt() + 1].id;
      _answerController.text = _answers[nextQuestionId] ?? '';
    } else {
      _submitQuestionnaire();
    }
  }

  void _previousQuestion() {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    if (_pageController.page!.toInt() > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeOut,
      );
      questionnaireService.previousQuestion();
      // Populate answer for the *new* current question (which is the previous one)
      final previousQuestionId = _questions[_pageController.page!.toInt() -1].id;
      _answerController.text = _answers[previousQuestionId] ?? '';
    }
  }

  Future<void> _getAiSuggestion() async {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final currentQuestion = _questions[questionnaireService.currentQuestionIndex];
    final currentUserProfile = profileService.userProfile;

    if (currentUserProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded for AI suggestion.')),
      );
      return;
    }

    final String userContext = currentUserProfile.bio ?? currentUserProfile.displayName ?? currentUserProfile.email;

    try {
      final suggestedAnswer = await questionnaireService.getAiSuggestedAnswer(
        currentQuestion.text,
        userContext,
      );
      _answerController.text = suggestedAnswer;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get AI suggestion: $e')),
      );
    }
  }

  void _submitQuestionnaire() async {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final currentUser = profileService.userProfile;

    if (currentUser == null || currentUser.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in or profile ID missing.')),
      );
      return;
    }

    // Ensure the last answer is saved
    final lastQuestionId = _questions[questionnaireService.currentQuestionIndex].id;
    _answers[lastQuestionId] = _answerController.text;

    try {
      await questionnaireService.submitAnswers(currentUser.userId, _answers); // FIXED: Correct arguments
      // Navigate to results screen or dashboard upon successful submission
      context.go('/compatibility-results'); // Or '/home'
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit questionnaire: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;
    final questionnaireService = Provider.of<QuestionnaireService>(context); // Watch for progress updates

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    if (_isLoadingQuestions) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        body: Center(
          child: LoadingIndicatorWidget(color: secondaryColor),
        ),
      );
    }

    if (_questionsError != null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _questionsError!,
                style: TextStyle(color: AppConstants.errorColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              ElevatedButton(
                onPressed: _fetchQuestionsAndInitialize,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
        body: Center(
          child: EmptyStateWidget( // Correctly imported and used
            message: 'No questions available. Please check back later.',
            onRefresh: _fetchQuestionsAndInitialize,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Questionnaire'),
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.go('/home'); // Allow user to exit questionnaire
            },
          ),
        ],
      ),
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: QuestionProgressIndicator( // Correctly imported and used
              currentQuestion: questionnaireService.currentQuestionIndex + 1,
              totalQuestions: questionnaireService.totalQuestions,
              progressColor: secondaryColor,
              backgroundColor: cardColor.withOpacity(0.5),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable manual swiping
              itemCount: _questions.length,
              onPageChanged: (index) {
                // This will be triggered by _nextQuestion and _previousQuestion
                // The service state is already updated there.
              },
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  child: QuestionCard( // Correctly imported and used
                    question: question.text,
                    isDarkMode: isDarkMode,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: AnswerInputField(
              controller: _answerController,
              onSubmitted: (answer) {
                final currentQuestionId = _questions[questionnaireService.currentQuestionIndex].id;
                _answers[currentQuestionId] = answer;
                _nextQuestion();
              },
              onAiSuggest: _getAiSuggestion, // Added AI suggestion button callback
              isDarkMode: isDarkMode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (questionnaireService.currentQuestionIndex > 0)
                  ElevatedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                    ),
                  ),
                const Spacer(), // Pushes buttons to ends
                ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: Icon(questionnaireService.currentQuestionIndex == _questions.length - 1
                      ? Icons.check_circle_outline_rounded
                      : Icons.arrow_forward_ios_rounded),
                  label: Text(questionnaireService.currentQuestionIndex == _questions.length - 1
                      ? 'Submit'
                      : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall), // Bottom padding
        ],
      ),
    );
  }
}