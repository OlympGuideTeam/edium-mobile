part of 'question.dart';

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<AnswerOption> options;
  final String? explanation;
  final int orderIndex;


  final Map<String, dynamic>? metadata;

  final int? maxScore;


  final String? imageId;

  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    required this.orderIndex,
    this.metadata,
    this.maxScore,
    this.imageId,
  });

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<AnswerOption>? options,
    String? explanation,
    int? orderIndex,
    Map<String, dynamic>? metadata,
    bool clearMetadata = false,
    int? maxScore,
    bool clearMaxScore = false,
    String? imageId,
    bool clearImageId = false,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      orderIndex: orderIndex ?? this.orderIndex,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      maxScore: clearMaxScore ? null : (maxScore ?? this.maxScore),
      imageId: clearImageId ? null : (imageId ?? this.imageId),
    );
  }
}

