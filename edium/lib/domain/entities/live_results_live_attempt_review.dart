part of 'live_results.dart';

class LiveAttemptReview {
  final String attemptId;
  final String status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<LiveAnswerReview> answers;

  const LiveAttemptReview({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory LiveAttemptReview.fromJson(Map<String, dynamic> json) =>
      LiveAttemptReview(
        attemptId: json['attempt_id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble(),
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : DateTime.now(),
        finishedAt: json['finished_at'] != null
            ? DateTime.parse(json['finished_at'] as String)
            : null,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) => LiveAnswerReview.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

