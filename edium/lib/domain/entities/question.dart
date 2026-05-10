
part 'question_question.dart';

enum QuestionType {
  singleChoice,
  multiChoice,

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

