import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionType;

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

class AnswerReviewModel {
  final String submissionId;
  final String questionId;
  final String questionType;
  final String questionText;
  final String? imageId;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  final List<TeacherAnswerOptionModel>? options;
  final Map<String, dynamic>? metadata;

  const AnswerReviewModel({
    required this.submissionId,
    required this.questionId,
    required this.questionType,
    required this.questionText,
    this.imageId,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.options,
    this.metadata,
  });

  factory AnswerReviewModel.fromJson(Map<String, dynamic> json) {
    return AnswerReviewModel(
      submissionId: json['submission_id'] as String,
      questionId: json['question_id'] as String,
      questionType: json['question_type'] as String? ?? 'single_choice',
      questionText: json['question_text'] as String? ?? '',
      imageId: json['image_id'] as String?,
      answerData:
          (json['answer_data'] as Map<String, dynamic>?) ?? const {},
      finalScore: (json['final_score'] as num?)?.toDouble(),
      finalSource: json['final_source'] as String?,
      finalFeedback: json['final_feedback'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) =>
              TeacherAnswerOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  AnswerReview toEntity() => AnswerReview(
        submissionId: submissionId,
        questionId: questionId,
        questionType: _parseQuestionType(questionType),
        questionText: questionText,
        imageId: imageId,
        answerData: answerData,
        finalScore: finalScore,
        finalSource: finalSource,
        finalFeedback: finalFeedback,
        options: options?.map((e) => e.toEntity()).toList(),
        metadata: metadata,
      );

  static QuizQuestionType _parseQuestionType(String t) {
    switch (t) {
      case 'multiple_choice':
        return QuizQuestionType.multipleChoice;
      case 'with_given_answer':
        return QuizQuestionType.withGivenAnswer;
      case 'with_free_answer':
        return QuizQuestionType.withFreeAnswer;
      case 'drag':
        return QuizQuestionType.drag;
      case 'connection':
        return QuizQuestionType.connection;
      default:
        return QuizQuestionType.singleChoice;
    }
  }
}

class AttemptReviewModel {
  final String attemptId;
  final String userId;
  final String status;
  final double? score;
  final String startedAt;
  final String? finishedAt;
  final List<AnswerReviewModel> answers;

  const AttemptReviewModel({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory AttemptReviewModel.fromJson(Map<String, dynamic> json) {
    return AttemptReviewModel(
      attemptId: json['attempt_id'] as String,
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble(),
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => AnswerReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AttemptReview toEntity() => AttemptReview(
        attemptId: attemptId,
        userId: userId,
        status: _parseStatus(status),
        score: score,
        startedAt: DateTime.parse(startedAt),
        finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
        answers: answers.map((e) => e.toEntity()).toList(),
      );

  static AttemptStatus _parseStatus(String s) {
    switch (s) {
      case 'grading':
        return AttemptStatus.grading;
      case 'graded':
        return AttemptStatus.graded;
      case 'completed':
        return AttemptStatus.completed;
      default:
        return AttemptStatus.inProgress;
    }
  }
}
