import 'package:edium/domain/entities/quiz_attempt.dart';

part 'quiz_attempt_model_quiz_question_for_student_model.dart';
part 'quiz_attempt_model_quiz_attempt_model.dart';
part 'quiz_attempt_model_answer_submission_result_model.dart';
part 'quiz_attempt_model_attempt_result_model.dart';


class QuestionOptionForStudentModel {
  final String id;
  final String text;

  const QuestionOptionForStudentModel({required this.id, required this.text});

  factory QuestionOptionForStudentModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionForStudentModel(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  QuestionOptionForStudent toEntity() =>
      QuestionOptionForStudent(id: id, text: text);
}

