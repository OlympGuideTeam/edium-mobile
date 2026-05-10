part of 'live_question.dart';

sealed class LiveQuestionStats {
  final int answeredCount;
  final int correctCount;
  final int? avgTimeMs;

  const LiveQuestionStats({
    required this.answeredCount,
    required this.correctCount,
    this.avgTimeMs,
  });

  factory LiveQuestionStats.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String? ?? 'binary';
    if (kind == 'choice') {
      return LiveChoiceStats.fromJson(json);
    }
    return LiveBinaryStats.fromJson(json);
  }
}

