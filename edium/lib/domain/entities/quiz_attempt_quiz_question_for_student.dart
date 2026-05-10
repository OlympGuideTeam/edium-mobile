part of 'quiz_attempt.dart';

class QuizQuestionForStudent {
  final String id;
  final QuizQuestionType type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<QuestionOptionForStudent>? options;
  final Map<String, dynamic>? metadata;

  const QuizQuestionForStudent({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    this.options,
    this.metadata,
  });
}

