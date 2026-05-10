part of 'live_question.dart';

class LiveQuestion {
  final String id;
  final QuestionType type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<LiveAnswerOption> options;
  final Map<String, dynamic>? metadata;

  const LiveQuestion({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    required this.options,
    this.metadata,
  });

  factory LiveQuestion.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'single_choice';
    return LiveQuestion(
      id: json['id'] as String,
      type: _questionTypeFromString(typeStr),
      text: json['text'] as String? ?? '',
      imageId: json['image_id'] as String?,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 10,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => LiveAnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static QuestionType _questionTypeFromString(String s) => switch (s) {
        'single_choice' => QuestionType.singleChoice,
        'multiple_choice' => QuestionType.multiChoice,
        'with_free_answer' => QuestionType.withFreeAnswer,
        'with_given_answer' => QuestionType.withGivenAnswer,
        'drag' => QuestionType.drag,
        'connection' => QuestionType.connection,
        _ => QuestionType.singleChoice,
      };
}

