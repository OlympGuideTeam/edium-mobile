import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;

class AttemptSummary {
  final String attemptId;
  final String userId;
  final String? userName;
  final AttemptStatus status;
  final double? score;

  const AttemptSummary({
    required this.attemptId,
    required this.userId,
    this.userName,
    required this.status,
    this.score,
  });
}
