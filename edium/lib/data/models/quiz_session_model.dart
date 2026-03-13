import 'package:edium/domain/entities/quiz_session.dart';

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

class QuizSessionModel {
  final String id;
  final String quizId;
  final String userId;
  final String status;
  final List<AnswerRecordModel> answers;
  final int? score;
  final int? totalQuestions;
  final String startedAt;
  final String? completedAt;

  const QuizSessionModel({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.status,
    required this.answers,
    this.score,
    this.totalQuestions,
    required this.startedAt,
    this.completedAt,
  });

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    return QuizSessionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => AnswerRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      score: json['score'] as int?,
      totalQuestions: json['total_questions'] as int?,
      startedAt: json['started_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }

  QuizSession toEntity() {
    return QuizSession(
      id: id,
      quizId: quizId,
      userId: userId,
      status: status == 'completed'
          ? SessionStatus.completed
          : SessionStatus.inProgress,
      answers: answers.map((e) => e.toEntity()).toList(),
      score: score,
      totalQuestions: totalQuestions,
      startedAt: DateTime.parse(startedAt),
      completedAt:
          completedAt != null ? DateTime.parse(completedAt!) : null,
    );
  }
}
