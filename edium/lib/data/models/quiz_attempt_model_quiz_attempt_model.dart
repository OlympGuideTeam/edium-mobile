part of 'quiz_attempt_model.dart';

class QuizAttemptModel {
  final String attemptId;
  final List<QuizQuestionForStudentModel> questions;

  const QuizAttemptModel({required this.attemptId, required this.questions});

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      attemptId: json['attempt_id'] as String,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionForStudentModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  QuizAttempt toEntity() => QuizAttempt(
        attemptId: attemptId,
        questions: questions.map((e) => e.toEntity()).toList(),
      );
}

