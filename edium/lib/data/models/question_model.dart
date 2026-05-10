import 'package:edium/domain/entities/question.dart';

part 'question_model_question_model.dart';


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

