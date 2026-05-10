part of 'live_question.dart';

class LiveBinaryStats extends LiveQuestionStats {
  final int incorrectCount;

  const LiveBinaryStats({
    required super.answeredCount,
    required super.correctCount,
    super.avgTimeMs,
    required this.incorrectCount,
  });

  factory LiveBinaryStats.fromJson(Map<String, dynamic> json) =>
      LiveBinaryStats(
        answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        avgTimeMs: (json['avg_time_ms'] as num?)?.toInt(),
        incorrectCount: (json['incorrect_count'] as num?)?.toInt() ?? 0,
      );
}

