part of 'live_question.dart';

class LiveChoiceStats extends LiveQuestionStats {
  final List<LiveOptionDistribution> distribution;

  const LiveChoiceStats({
    required super.answeredCount,
    required super.correctCount,
    super.avgTimeMs,
    required this.distribution,
  });

  factory LiveChoiceStats.fromJson(Map<String, dynamic> json) =>
      LiveChoiceStats(
        answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        avgTimeMs: (json['avg_time_ms'] as num?)?.toInt(),
        distribution: (json['distribution'] as List<dynamic>? ?? [])
            .map((e) =>
                LiveOptionDistribution.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

