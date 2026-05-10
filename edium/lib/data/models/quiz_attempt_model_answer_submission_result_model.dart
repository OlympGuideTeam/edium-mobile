part of 'quiz_attempt_model.dart';

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

