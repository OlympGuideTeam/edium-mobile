import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;

class AttemptSummary {
  final String attemptId;
  final String userId;
  final AttemptStatus status;
  final double? score;

  const AttemptSummary({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
  });
}
