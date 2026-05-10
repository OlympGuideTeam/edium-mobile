part of 'library_quiz_datasource_mock.dart';

class _AttemptState {
  final String sessionId;
  final String quizId;
  final List<QuizQuestionForStudentModel> questions;
  final Map<String, Map<String, dynamic>> answers = {};
  final DateTime startedAt;
  DateTime? finishedAt;

  _AttemptState({
    required this.sessionId,
    required this.quizId,
    required this.questions,
    required this.startedAt,
  });
}

