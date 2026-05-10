part of 'attempt_review_model.dart';

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

