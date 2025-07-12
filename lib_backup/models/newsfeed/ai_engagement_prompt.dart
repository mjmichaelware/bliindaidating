// lib/models/newsfeed/ai_engagement_prompt.dart
class AIEngagementPrompt {
  final String id;
  final String tip;

  AIEngagementPrompt({
    required this.id,
    required this.tip,
  });

  factory AIEngagementPrompt.fromJson(Map<String, dynamic> json) {
    return AIEngagementPrompt(
      id: json['id'] as String,
      tip: json['tip'] as String,
    );
  }
}