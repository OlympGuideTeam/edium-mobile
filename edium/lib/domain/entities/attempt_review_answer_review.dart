part of 'attempt_review.dart';

class AnswerReview {
  final String submissionId;
  final String questionId;
  final QuizQuestionType questionType;
  final String questionText;
  final String? imageId;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  final List<TeacherAnswerOption>? options;
  final Map<String, dynamic>? metadata;

  const AnswerReview({
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
}

