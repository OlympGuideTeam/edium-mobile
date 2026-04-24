import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionType;

class TeacherAnswerOption {
  final String id;
  final String text;
  final bool isCorrect;

  const TeacherAnswerOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}

class AnswerReview {
  final String submissionId;
  final String questionId;
  final QuizQuestionType questionType;
  final String questionText;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource; // auto | llm | teacher
  final String? finalFeedback;
  final List<TeacherAnswerOption>? options;
  final Map<String, dynamic>? metadata;

  const AnswerReview({
    required this.submissionId,
    required this.questionId,
    required this.questionType,
    required this.questionText,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.options,
    this.metadata,
  });
}

class AttemptReview {
  final String attemptId;
  final String userId;
  final AttemptStatus status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<AnswerReview> answers;

  const AttemptReview({
    required this.attemptId,
    required this.userId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });
}
