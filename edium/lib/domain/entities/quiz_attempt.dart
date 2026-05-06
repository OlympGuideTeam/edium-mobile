enum QuizQuestionType {
  singleChoice,
  multipleChoice,
  withGivenAnswer,
  withFreeAnswer,
  drag,
  connection,
}

class QuestionOptionForStudent {
  final String id;
  final String text;

  const QuestionOptionForStudent({required this.id, required this.text});
}

class QuizQuestionForStudent {
  final String id;
  final QuizQuestionType type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<QuestionOptionForStudent>? options;
  final Map<String, dynamic>? metadata;

  const QuizQuestionForStudent({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    this.options,
    this.metadata,
  });
}

class QuizAttempt {
  final String attemptId;
  final List<QuizQuestionForStudent> questions;

  const QuizAttempt({required this.attemptId, required this.questions});

  int get maxPossibleScore =>
      questions.fold(0, (sum, q) => sum + q.maxScore);
}

enum AttemptStatus { inProgress, grading, graded, completed }

class AnswerSubmissionResult {
  final String questionId;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  // Правильные ответы, возвращаемые сервером в результате попытки.
  // Ключи: correct_option_ids, correct_answers, correct_order, correct_pairs.
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

class AttemptResult {
  final String attemptId;
  final AttemptStatus status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<AnswerSubmissionResult> answers;

  const AttemptResult({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  bool get hasPendingEvaluation =>
      answers.any((a) => a.finalScore == null);
}
