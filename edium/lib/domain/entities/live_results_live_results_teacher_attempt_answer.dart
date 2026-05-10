part of 'live_results.dart';

class LiveResultsTeacherAttemptAnswer {
  final String questionId;
  final bool isCorrect;
  final double score;

  const LiveResultsTeacherAttemptAnswer({
    required this.questionId,
    required this.isCorrect,
    required this.score,
  });

  factory LiveResultsTeacherAttemptAnswer.fromJson(
          Map<String, dynamic> json) =>
      LiveResultsTeacherAttemptAnswer(
        questionId: json['question_id'] as String? ?? '',
        isCorrect: json['is_correct'] as bool? ?? false,
        score: (json['score'] as num?)?.toDouble() ?? 0,
      );
}

