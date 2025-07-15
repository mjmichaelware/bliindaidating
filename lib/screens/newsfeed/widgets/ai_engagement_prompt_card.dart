// lib/screens/newsfeed/widgets/ai_engagement_prompt_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/ai_logic_service.dart'; // Import AiLogicService
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this

class AiEngagementPromptCard extends StatefulWidget {
  const AiEngagementPromptCard({super.key});

  @override
  State<AiEngagementPromptCard> createState() => _AiEngagementPromptCardState();
}

class _AiEngagementPromptCardState extends State<AiEngagementPromptCard> {
  String? _prompt;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPrompt();
  }

  Future<void> _fetchPrompt() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final aiService = Provider.of<AiLogicService>(context, listen: false);
      // Fetch a daily prompt, or you could create a new backend endpoint
      // specifically for newsfeed engagement prompts if they differ.
      final fetchedPrompt = await aiService.generateDailyPrompt(context: 'newsfeed engagement, conversation starter');
      setState(() {
        _prompt = fetchedPrompt;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load prompt: $e';
        debugPrint('Error fetching AI engagement prompt: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);
    final isDarkMode = theme.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? Center(
              child: LoadingIndicatorWidget(
                color: isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor,
                size: 20,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: TextStyle(
                      color: AppConstants.errorColor,
                      fontSize: AppConstants.fontSizeSmall,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Engagement Prompt:',
                      style: TextStyle(
                        color: isDarkMode ? AppConstants.textHighEmphasis : AppConstants.lightTextHighEmphasis,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Text(
                      _prompt ?? 'No prompt available.',
                      style: TextStyle(
                        color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                        fontSize: AppConstants.fontSizeBody,
                        fontStyle: _prompt == null ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton.icon(
                        onPressed: _fetchPrompt, // Allow refreshing the prompt
                        icon: Icon(Icons.refresh, size: AppConstants.fontSizeMedium, color: AppConstants.secondaryColor),
                        label: Text(
                          'New Prompt',
                          style: TextStyle(
                            color: AppConstants.secondaryColor,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}