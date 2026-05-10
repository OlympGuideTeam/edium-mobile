part of 'live_results.dart';

class LiveResultsTeacherAttempt {
  final int position;
  final String attemptId;
  final String? userId;
  final String name;
  final double score;
  final double maxScore;
  final int correctCount;
  final List<LiveResultsTeacherAttemptAnswer> answers;

  const LiveResultsTeacherAttempt({
    required this.position,
    required this.attemptId,
    this.userId,
    required this.name,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.answers,
  });

  factory LiveResultsTeacherAttempt.fromJson(Map<String, dynamic> json) =>
      LiveResultsTeacherAttempt(
        position: (json['position'] as num?)?.toInt() ?? 0,
        attemptId: json['attempt_id'] as String? ?? '',
        userId: json['user_id'] as String?,
        name: json['name'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) => LiveResultsTeacherAttemptAnswer.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

