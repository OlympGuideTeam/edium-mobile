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
    final explicitCorrectData = json['correct_data'] as Map<String, dynamic>?;
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final options = json['options'] as List<dynamic>?;

    Map<String, dynamic>? correctData = explicitCorrectData ?? metadata;

    // Extract correct_option_ids from options[].is_correct for choice questions
    if (options != null) {
      final correctIds = options
          .cast<Map<String, dynamic>>()
          .where((o) => o['is_correct'] == true)
          .map((o) => o['id'].toString())
          .toList();
      if (correctIds.isNotEmpty) {
        correctData = {...?correctData, 'correct_option_ids': correctIds};
      }
    }

    return AnswerSubmissionResultModel(
      questionId: json['question_id'] as String,
      answerData: json['answer_data'] as Map<String, dynamic>? ?? {},
      finalScore: (json['final_score'] as num?)?.toDouble(),
      finalSource: json['final_source'] as String?,
      finalFeedback: json['final_feedback'] as String?,
      correctData: correctData,
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

