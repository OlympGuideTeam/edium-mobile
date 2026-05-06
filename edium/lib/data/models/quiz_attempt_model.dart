import 'package:edium/domain/entities/quiz_attempt.dart';

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

class QuizQuestionForStudentModel {
  final String id;
  final String type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<QuestionOptionForStudentModel>? options;
  final Map<String, dynamic>? metadata;

  const QuizQuestionForStudentModel({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    this.options,
    this.metadata,
  });

  factory QuizQuestionForStudentModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionForStudentModel(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      imageId: json['image_id'] as String?,
      maxScore: json['max_score'] as int? ?? 10,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuestionOptionForStudentModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'text': text,
        if (imageId != null) 'image_id': imageId,
        'max_score': maxScore,
        if (options != null)
          'options': options!.map((e) => e.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };

  QuizQuestionForStudent toEntity() {
    final qType = _parseType(type);
    return QuizQuestionForStudent(
      id: id,
      type: qType,
      text: text,
      imageId: imageId,
      maxScore: maxScore,
      options: options?.map((e) => e.toEntity()).toList(),
      metadata: metadata,
    );
  }

  static QuizQuestionType _parseType(String t) {
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

class AnswerSubmissionResultModel {
  final String questionId;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  final Map<String, dynamic>? correctData;

  const AnswerSubmissionResultModel({
    required this.questionId,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.correctData,
  });

  factory AnswerSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return AnswerSubmissionResultModel(
      questionId: json['question_id'] as String,
      answerData: json['answer_data'] as Map<String, dynamic>? ?? {},
      finalScore: (json['final_score'] as num?)?.toDouble(),
      finalSource: json['final_source'] as String?,
      finalFeedback: json['final_feedback'] as String?,
      correctData: json['correct_data'] as Map<String, dynamic>?,
    );
  }

  AnswerSubmissionResult toEntity() => AnswerSubmissionResult(
        questionId: questionId,
        answerData: answerData,
        finalScore: finalScore,
        finalSource: finalSource,
        finalFeedback: finalFeedback,
        correctData: correctData,
      );
}

class AttemptResultModel {
  final String attemptId;
  final String status;
  final double? score;
  final String startedAt;
  final String? finishedAt;
  final List<AnswerSubmissionResultModel> answers;

  const AttemptResultModel({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    return AttemptResultModel(
      attemptId: json['attempt_id'] as String,
      status: json['status'] as String? ?? 'completed',
      score: (json['score'] as num?)?.toDouble(),
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => AnswerSubmissionResultModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  AttemptResult toEntity() {
    AttemptStatus st;
    switch (status) {
      case 'grading':
        st = AttemptStatus.grading;
        break;
      case 'graded':
        st = AttemptStatus.graded;
        break;
      case 'completed':
        st = AttemptStatus.completed;
        break;
      default:
        st = AttemptStatus.inProgress;
    }
    return AttemptResult(
      attemptId: attemptId,
      status: st,
      score: score,
      startedAt: DateTime.parse(startedAt),
      finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
      answers: answers.map((e) => e.toEntity()).toList(),
    );
  }
}
