// lib/screens/questionnaire/questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/questionaire_service.dart'; // Import QuestionnaireService
import 'package:bliindaidating/services/profile_service.dart'; // Import ProfileService for user context
import 'package:bliindaidating/models/questionnaire/question.dart'; // Import Question model
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this
import 'package:bliindaidating/screens/questionnaire/widgets/answer_input_field.dart'; // Import your AnswerInputField

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Question> _questions = []; // Dynamic list of questions
  Map<String, String> _answers = {}; // Store answers by question ID
  bool _isLoadingQuestions = true;
  String? _errorLoadingQuestions;

  @override
  void initState() {
    super.initState();
    _fetchQuestions(); // Fetch questions on init
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _errorLoadingQuestions = null;
    });
    try {
      final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
      final fetchedQuestions = await questionnaireService.fetchQuestions();
      setState(() {
        _questions = fetchedQuestions;
        // Initialize answers map with any existing answers from user profile or empty strings
        // For now, it initializes with empty strings. Later, you'd load from userProfile.questionnaireAnswers
        for (var q in _questions) {
          _answers[q.id] = ''; // Initialize with empty string
        }
      });
    } catch (e) {
      setState(() {
        _errorLoadingQuestions = 'Failed to load questions: $e';
        debugPrint('Error fetching questions: $e');
      });
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  void _onAnswerChanged(String questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  Future<void> _getAiSuggestion(String questionId, String questionText) async {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);

    final currentUserProfile = profileService.userProfile;
    if (currentUserProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your basic profile first to get AI suggestions.')),
      );
      return;
    }

    // Prepare user context for the AI
    final Map<String, dynamic> userContext = currentUserProfile.toJson();
    // Add existing answers to context if helpful for AI
    userContext['existing_answers'] = _answers;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting AI suggestion...')),
    );

    final suggestedAnswer = await questionnaireService.getAiSuggestedAnswer(questionText, userContext);

    if (suggestedAnswer != null) {
      setState(() {
        _answers[questionId] = suggestedAnswer;
      });
      // Find the TextEditingController associated with this question and update it
      // This requires a more robust way to manage controllers, e.g., a Map<String, TextEditingController>
      // For now, this just updates the state, and the AnswerInputField will rebuild.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get AI suggestion. Try again.')),
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < _questions.length - 1) { // Use _questions.length
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _submitQuestionnaire();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuestionnaire() async {
    final questionnaireService = Provider.of<QuestionnaireService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);

    final currentUser = profileService.userProfile;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit: User profile not loaded.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting questionnaire...')),
    );

    try {
      await questionnaireService.submitAnswers(currentUser.userId, _answers);

      // After successful submission, update the user's profile in ProfileService
      // to reflect the new questionnaire answers and potentially phase completion.
      final updatedProfile = currentUser.copyWith(
        questionnaireAnswers: _answers,
        // You might set isPhase2Complete = true here if this questionnaire is the final step
        // For now, we assume it's an ongoing questionnaire not directly tied to phase completion.
      );
      await profileService.updateProfile(updatedProfile); // Persist updated profile to Supabase

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questionnaire Submitted Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // You might want to navigate away or show a success screen
      // context.go('/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit questionnaire: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      debugPrint('Error submitting questionnaire: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    final Color primaryColor = isDarkMode ? AppConstants.primaryColor : AppConstants.lightPrimaryColor;
    final Color secondaryColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color surfaceColor = isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;


    return Container(
      color: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // Header / Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Questionnaire Progress',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Page ${_currentPage + 1} of ${_questions.length}', // Use _questions.length
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: textMediumEmphasis,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          // Progress Bar
          LinearProgressIndicator(
            value: _questions.isEmpty ? 0 : (_currentPage + 1) / _questions.length, // Handle empty questions
            backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            color: secondaryColor,
            minHeight: 8.0,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          // Main Content Area for Questions
          Expanded(
            child: _isLoadingQuestions
                ? const Center(child: LoadingIndicatorWidget())
                : _errorLoadingQuestions != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorLoadingQuestions!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppConstants.errorColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            ElevatedButton(
                              onPressed: _fetchQuestions,
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
                    : _questions.isEmpty
                        ? Center(
                            child: EmptyStateWidget(
                              message: 'No questionnaire questions available.',
                              onRefresh: _fetchQuestions,
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: _questions.length, // Use _questions.length
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final question = _questions[index];
                              return _buildQuestionPage(
                                context,
                                question, // Pass the actual question object
                                _answers[question.id] ?? '', // Pass current answer
                                (answer) => _onAnswerChanged(question.id, answer), // Callback for answer change
                                () => _getAiSuggestion(question.id, question.text), // Callback for AI suggestion
                                isDarkMode,
                              );
                            },
                          ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              if (_currentPage > 0)
                ElevatedButton.icon(
                  onPressed: _goToPreviousPage,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.8),
                    foregroundColor: AppConstants.textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    ),
                  ),
                ),
              // Spacer to push buttons to ends if only one is visible
              if (_currentPage == 0 && _questions.length > 1) // Use _questions.length
                const Spacer(),

              // Next / Submit Button
              ElevatedButton.icon(
                onPressed: _goToNextPage,
                icon: Icon(_currentPage == _questions.length - 1 // Use _questions.length
                    ? Icons.done_all_rounded
                    : Icons.arrow_forward_ios_rounded),
                label: Text(_currentPage == _questions.length - 1 // Use _questions.length
                    ? 'Submit Questionnaire'
                    : 'Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: AppConstants.textColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(
    BuildContext context,
    Question question, // Pass Question object
    String currentAnswer,
    ValueChanged<String> onAnswerChanged,
    VoidCallback onAiSuggestion,
    bool isDarkMode,
  ) {
    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color textMediumEmphasis = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color cardColor = isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${question.id}', // Display question ID or number
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeExtraLarge,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  question.text, // Display the actual question text
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: textMediumEmphasis,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                // Use your AnswerInputField widget
                AnswerInputField(
                  initialValue: currentAnswer,
                  onChanged: onAnswerChanged,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onAiSuggestion,
                    icon: Icon(Icons.auto_awesome, color: AppConstants.secondaryColor),
                    label: Text(
                      'AI Suggest Answer',
                      style: TextStyle(color: AppConstants.secondaryColor, fontSize: AppConstants.fontSizeSmall),
                    ),
                  ),
                ),
                // Add more complex question widgets here based on question.type
                // e.g., if (question.type == QuestionType.multipleChoice) { ... }
              ],
            ),
          ),
        ],
      ),
    );
  }
}