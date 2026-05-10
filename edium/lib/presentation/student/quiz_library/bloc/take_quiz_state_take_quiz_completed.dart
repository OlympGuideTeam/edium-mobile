part of 'take_quiz_state.dart';

class TakeQuizCompleted extends TakeQuizState {
  final AttemptResult result;
  final int maxPossibleScore;
  final String quizTitle;
  final List<QuizQuestionForStudent> questions;

  const TakeQuizCompleted({
    required this.result,
    required this.maxPossibleScore,
    required this.quizTitle,
    required this.questions,
  });

  @override
  List<Object?> get props =>
      [result, maxPossibleScore, quizTitle, questions];
}

