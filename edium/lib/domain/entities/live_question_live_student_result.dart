part of 'live_question.dart';

class LiveStudentResult {
  final bool isCorrect;
  final double score;
  final double maxScore;
  final int? timeTakenMs;

  const LiveStudentResult({
    required this.isCorrect,
    required this.score,
    required this.maxScore,
    this.timeTakenMs,
  });

  factory LiveStudentResult.fromJson(Map<String, dynamic> json) =>
      LiveStudentResult(
        isCorrect: json['is_correct'] as bool? ?? false,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
        timeTakenMs: (json['time_taken_ms'] as num?)?.toInt(),
      );
}

