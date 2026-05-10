part of 'attempt_review.dart';

class AttemptReview {
  final String attemptId;
  final String userId;
  final AttemptStatus status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<AnswerReview> answers;

  const AttemptReview({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });
}

