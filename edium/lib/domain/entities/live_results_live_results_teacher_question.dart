part of 'live_results.dart';

class LiveResultsTeacherQuestion {
  final String questionId;
  final int orderIndex;
  final String text;
  final String type;
  final double correctRate;
  final LiveQuestionStats stats;

  const LiveResultsTeacherQuestion({
    required this.questionId,
    required this.orderIndex,
    required this.text,
    required this.type,
    required this.correctRate,
    required this.stats,
  });

  factory LiveResultsTeacherQuestion.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final answeredCount = (json['answered_count'] as num?)?.toInt() ?? 0;
    final correctCount = (json['correct_count'] as num?)?.toInt() ?? 0;
    final avgTimeMs = (json['avg_time_ms'] as num?)?.toInt();
    final isChoice = type == 'single_choice' || type == 'multiple_choice';

    final LiveQuestionStats stats;
    if (isChoice) {
      stats = LiveChoiceStats(
        answeredCount: answeredCount,
        correctCount: correctCount,
        avgTimeMs: avgTimeMs,
        distribution: (json['distribution'] as List<dynamic>? ?? [])
            .map((e) =>
                LiveOptionDistribution.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else {
      stats = LiveBinaryStats(
        answeredCount: answeredCount,
        correctCount: correctCount,
        avgTimeMs: avgTimeMs,
        incorrectCount: answeredCount - correctCount,
      );
    }

    return LiveResultsTeacherQuestion(
      questionId: json['question_id'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      type: type,
      correctRate: (json['correct_rate'] as num?)?.toDouble() ?? 0,
      stats: stats,
    );
  }
}

