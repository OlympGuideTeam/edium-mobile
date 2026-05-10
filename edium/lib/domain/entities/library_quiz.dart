
part 'library_quiz_quiz_default_settings.dart';
part 'library_quiz_library_quiz.dart';

class QuizAttemptSummary {
  final String id;
  final String sessionId;
  final String sessionType;
  final String status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const QuizAttemptSummary({
    required this.id,
    required this.sessionId,
    required this.sessionType,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
  });
}

