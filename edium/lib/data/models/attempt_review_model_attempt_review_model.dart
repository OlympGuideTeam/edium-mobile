part of 'attempt_review_model.dart';

class AttemptReviewModel {
  final String attemptId;
  final String userId;
  final String status;
  final double? score;
  final String startedAt;
  final String? finishedAt;
  final List<AnswerReviewModel> answers;

  const AttemptReviewModel({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory AttemptReviewModel.fromJson(Map<String, dynamic> json) {
    return AttemptReviewModel(
      attemptId: json['attempt_id'] as String,
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble(),
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => AnswerReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AttemptReview toEntity() => AttemptReview(
        attemptId: attemptId,
        userId: userId,
        status: _parseStatus(status),
        score: score,
        startedAt: DateTime.parse(startedAt),
        finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
        answers: answers.map((e) => e.toEntity()).toList(),
      );

  static AttemptStatus _parseStatus(String s) {
    switch (s) {
      case 'grading':
        return AttemptStatus.grading;
      case 'graded':
        return AttemptStatus.graded;
      case 'completed':
        return AttemptStatus.completed;
      case 'published':
        return AttemptStatus.published;
      default:
        return AttemptStatus.inProgress;
    }
  }
}

