// lib/models/questionnaire/question.dart

import 'package:flutter/foundation.dart';

class Question {
  final String id;
  final String text;
  final List<String> options;
  final String type;

  Question({
    required this.id,
    required this.text,
    this.options = const [],
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'type': type,
    };
  }
}