part of 'quiz_attempt.dart';

class QuizAttempt {
  final String attemptId;
  final List<QuizQuestionForStudent> questions;

  const QuizAttempt({required this.attemptId, required this.questions});

  int get maxPossibleScore =>
      questions.fold(0, (sum, q) => sum + q.maxScore);
}

enum AttemptStatus { inProgress, grading, graded, completed, published }

