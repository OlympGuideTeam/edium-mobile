part of 'library_quiz_datasource_mock.dart';

class _QuizQuestionFull {
  final String id;
  final String? correctOptionId;
  final Set<String> correctOptionIds;
  final List<String>? correctAnswers;
  final List<String>? correctOrder;
  final Map<String, String>? correctPairs;

  _QuizQuestionFull({
    required this.id,
    this.correctOptionId,
    Set<String>? correctOptionIds,
    this.correctAnswers,
    this.correctOrder,
    this.correctPairs,
  }) : correctOptionIds = correctOptionIds ?? {};
}

