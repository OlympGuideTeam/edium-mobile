import 'package:edium/domain/entities/quiz_session.dart';

part 'quiz_session_model_quiz_session_model.dart';


class AnswerRecordModel {
  final String questionId;
  final dynamic answer;
  final bool? correct;
  final String? explanation;

  const AnswerRecordModel({
    required this.questionId,
    required this.answer,
    this.correct,
    this.explanation,
  });

  factory AnswerRecordModel.fromJson(Map<String, dynamic> json) {
    return AnswerRecordModel(
      questionId: json['question_id'] as String,
      answer: json['answer'],
      correct: json['correct'] as bool?,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'answer': answer,
        if (correct != null) 'correct': correct,
        if (explanation != null) 'explanation': explanation,
      };

  AnswerRecord toEntity() => AnswerRecord(
        questionId: questionId,
        answer: answer,
        correct: correct,
        explanation: explanation,
      );
}

