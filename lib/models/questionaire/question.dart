import 'package:flutter/foundation.dart'; // For @required

class Question {
  final String id;
  final String text;
  final List<String> options; // For single_choice and multiple_choice
  final String type; // e.g., 'single_choice', 'multiple_choice', 'text_input'

  Question({
    required this.id,
    required this.text,
    this.options = const [],
    required this.type,
  });

  // Factory constructor to create a Question from JSON (useful for real data from Supabase)
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      type: json['type'] as String,
    );
  }

  // Method to convert a Question to JSON (useful for sending answers to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'type': type,
    };
  }
}