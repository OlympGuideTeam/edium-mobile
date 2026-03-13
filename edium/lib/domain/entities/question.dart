enum QuestionType { singleChoice, multiChoice, textInput }

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

  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    required this.orderIndex,
  });

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<AnswerOption>? options,
    String? explanation,
    int? orderIndex,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
