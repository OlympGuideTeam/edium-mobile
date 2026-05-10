part of 'quiz_attempt.dart';

class AnswerSubmissionResult {
  final String questionId;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;


  final Map<String, dynamic>? correctData;

  const AnswerSubmissionResult({
    required this.questionId,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.correctData,
  });
}

