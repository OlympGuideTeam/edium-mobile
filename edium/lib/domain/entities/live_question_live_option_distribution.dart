part of 'live_question.dart';

class LiveOptionDistribution {
  final String optionId;
  final int count;
  final bool isCorrect;

  const LiveOptionDistribution({
    required this.optionId,
    required this.count,
    required this.isCorrect,
  });

  factory LiveOptionDistribution.fromJson(Map<String, dynamic> json) =>
      LiveOptionDistribution(
        optionId: json['option_id'] as String,
        count: (json['count'] as num?)?.toInt() ?? 0,
        isCorrect: json['is_correct'] as bool? ?? false,
      );
}

