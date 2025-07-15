// lib/models/questionnaire/question.dart

/// Enum to define different types of questions.
enum QuestionType {
  text,
  multipleChoice,
  slider,
  // Add more types as needed
}

/// Represents a single question in the questionnaire.
class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options; // For multipleChoice questions

  Question({
    required this.id,
    required this.text,
    this.type = QuestionType.text, // Default to text
    this.options,
  });

  // Factory constructor to create a Question from a JSON map
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.text, // Default if type not found
      ),
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  // Method to convert a Question to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'options': options,
    };
  }
}