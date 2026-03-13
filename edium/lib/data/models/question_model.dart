import 'package:edium/domain/entities/question.dart';

class AnswerOptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  const AnswerOptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return AnswerOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_correct': isCorrect,
      };

  AnswerOption toEntity() =>
      AnswerOption(id: id, text: text, isCorrect: isCorrect);

  factory AnswerOptionModel.fromEntity(AnswerOption e) =>
      AnswerOptionModel(id: e.id, text: e.text, isCorrect: e.isCorrect);
}

class QuestionModel {
  final String id;
  final String text;
  final String type;
  final List<AnswerOptionModel> options;
  final String? explanation;
  final String? correctAnswer; // for text_input type
  final int orderIndex;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.explanation,
    this.correctAnswer,
    required this.orderIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => AnswerOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String?,
      correctAnswer: json['correct_answer'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type,
        'options': options.map((e) => e.toJson()).toList(),
        if (explanation != null) 'explanation': explanation,
        if (correctAnswer != null) 'correct_answer': correctAnswer,
        'order_index': orderIndex,
      };

  Question toEntity() {
    QuestionType qType;
    switch (type) {
      case 'multi_choice':
        qType = QuestionType.multiChoice;
        break;
      case 'text_input':
        qType = QuestionType.textInput;
        break;
      default:
        qType = QuestionType.singleChoice;
    }
    return Question(
      id: id,
      text: text,
      type: qType,
      options: options.map((e) => e.toEntity()).toList(),
      explanation: explanation,
      orderIndex: orderIndex,
    );
  }

  factory QuestionModel.fromEntity(Question q) {
    String typeStr;
    switch (q.type) {
      case QuestionType.multiChoice:
        typeStr = 'multi_choice';
        break;
      case QuestionType.textInput:
        typeStr = 'text_input';
        break;
      default:
        typeStr = 'single_choice';
    }
    return QuestionModel(
      id: q.id,
      text: q.text,
      type: typeStr,
      options: q.options.map(AnswerOptionModel.fromEntity).toList(),
      explanation: q.explanation,
      orderIndex: q.orderIndex,
    );
  }
}
