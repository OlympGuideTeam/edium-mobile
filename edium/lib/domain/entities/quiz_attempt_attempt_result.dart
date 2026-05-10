part of 'quiz_attempt.dart';

class AttemptResult {
  final String attemptId;
  final AttemptStatus status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<AnswerSubmissionResult> answers;

  const AttemptResult({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  bool get hasPendingEvaluation =>
      answers.any((a) => a.finalScore == null);
}

