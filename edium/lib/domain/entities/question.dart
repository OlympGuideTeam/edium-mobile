enum QuestionType {
  singleChoice,
  multiChoice,
  /// Riddler: `with_free_answer`.
  withFreeAnswer,
  withGivenAnswer,
  drag,
  connection,
}

class AnswerOption {
  final String id;
  final String text;
  final bool isCorrect;

  const AnswerOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  AnswerOption copyWith({String? id, String? text, bool? isCorrect}) {
    return AnswerOption(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<AnswerOption> options;
  final String? explanation;
  final int orderIndex;

  /// Riddler payload (`with_given_answer`, `drag`, `connection`).
  final Map<String, dynamic>? metadata;

  final int? maxScore;

  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    required this.orderIndex,
    this.metadata,
    this.maxScore,
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
    );
  }
}
