import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalQuestionPages = 5; // Example: 5 pages of questions

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _totalQuestionPages - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      // This is the last page, handle submission
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

  void _submitQuestionnaire() {
    // TODO: Implement actual submission logic here
    // For now, just show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Questionnaire Submitted! (Dummy Action)'),
        backgroundColor: Colors.green,
      ),
    );
    // You might want to update profile status or navigate away
    // context.go('/dashboard');
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
          // Header / Progress Indicator (Optional, but good UX)
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
                  'Page ${_currentPage + 1} of $_totalQuestionPages',
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
            value: (_currentPage + 1) / _totalQuestionPages,
            backgroundColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            color: secondaryColor,
            minHeight: 8.0,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          const SizedBox(height: AppConstants.spacingLarge),

          // Main Content Area for Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalQuestionPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildQuestionPage(context, index, isDarkMode);
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
              if (_currentPage == 0 && _totalQuestionPages > 1)
                const Spacer(), // Pushes next button to right if on first page

              // Next / Submit Button
              ElevatedButton.icon(
                onPressed: _goToNextPage,
                icon: Icon(_currentPage == _totalQuestionPages - 1
                    ? Icons.done_all_rounded
                    : Icons.arrow_forward_ios_rounded),
                label: Text(_currentPage == _totalQuestionPages - 1
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

  Widget _buildQuestionPage(BuildContext context, int pageIndex, bool isDarkMode) {
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
                  'Question Page ${pageIndex + 1}',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeExtraLarge,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                Text(
                  'This is placeholder content for questions on page ${pageIndex + 1}. '
                  'Here you would integrate various input fields, '
                  'radio buttons, checkboxes, or sliders to capture user responses. '
                  'For example, a text input for an open-ended question, '
                  'or a set of multiple-choice options.',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeBody,
                    color: textMediumEmphasis,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                // Example of a dummy input field for demonstration
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Your Answer for Page ${pageIndex + 1}',
                    labelStyle: TextStyle(color: textMediumEmphasis),
                    hintText: 'Type your response here...',
                    hintStyle: TextStyle(color: textMediumEmphasis.withOpacity(0.7)),
                    filled: true,
                    fillColor: isDarkMode ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      borderSide: BorderSide(color: AppConstants.secondaryColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      borderSide: BorderSide(color: AppConstants.borderColor.withOpacity(0.5), width: 1.0),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                  maxLines: 3,
                ),
                // Add more complex question widgets here for actual implementation
                // e.g., RadioGroup, CheckboxList, Sliders etc.
              ],
            ),
          ),
        ],
      ),
    );
  }
}