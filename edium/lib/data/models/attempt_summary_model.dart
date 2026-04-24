import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;

class AttemptSummaryModel {
  final String attemptId;
  final String userId;
  final String status;
  final double? score;

  const AttemptSummaryModel({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
  });

  factory AttemptSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttemptSummaryModel(
      attemptId: json['attempt_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  AttemptSummary toEntity() => AttemptSummary(
        attemptId: attemptId,
        userId: userId,
        status: _parseStatus(status),
        score: score,
      );

  static AttemptStatus _parseStatus(String s) {
    switch (s) {
      case 'grading':
        return AttemptStatus.grading;
      case 'graded':
        return AttemptStatus.graded;
      case 'completed':
        return AttemptStatus.completed;
      default:
        return AttemptStatus.inProgress;
    }
  }
}
