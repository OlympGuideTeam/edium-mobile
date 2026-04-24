class TestSessionMeta {
  final String sessionId;
  final String quizId;
  final String title;
  final String? description;
  final int questionCount;
  final bool needEvaluation;
  final int? totalTimeLimitSec;
  final bool? shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const TestSessionMeta({
    required this.sessionId,
    required this.quizId,
    required this.title,
    this.description,
    required this.questionCount,
    required this.needEvaluation,
    this.totalTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });

  bool get hasTimeLimit => totalTimeLimitSec != null;

  int? get timeLimitMinutes =>
      totalTimeLimitSec != null ? (totalTimeLimitSec! / 60).ceil() : null;
}
