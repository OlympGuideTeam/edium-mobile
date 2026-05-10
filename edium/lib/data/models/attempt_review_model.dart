import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionType;

part 'attempt_review_model_answer_review_model.dart';
part 'attempt_review_model_attempt_review_model.dart';


class TeacherAnswerOptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  const TeacherAnswerOptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory TeacherAnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return TeacherAnswerOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  TeacherAnswerOption toEntity() =>
      TeacherAnswerOption(id: id, text: text, isCorrect: isCorrect);
}

