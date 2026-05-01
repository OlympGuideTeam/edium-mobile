import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:equatable/equatable.dart';

abstract class TakeQuizState extends Equatable {
  const TakeQuizState();
  @override
  List<Object?> get props => [];
}

class TakeQuizInitial extends TakeQuizState {
  const TakeQuizInitial();
}

class TakeQuizLoading extends TakeQuizState {
  const TakeQuizLoading();
}

class TakeQuizInProgress extends TakeQuizState {
  final QuizAttempt attempt;
  final String quizTitle;
  final int currentIndex;
  // questionId → answerData (null means not answered yet)
  final Map<String, Map<String, dynamic>?> answers;
  final int? remainingSeconds;
  final bool isSubmitting;

  const TakeQuizInProgress({
    required this.attempt,
    required this.quizTitle,
    required this.currentIndex,
    required this.answers,
    this.remainingSeconds,
    this.isSubmitting = false,
  });

  QuizQuestionForStudent get currentQuestion =>
      attempt.questions[currentIndex];

  Map<String, dynamic>? get currentAnswer =>
      answers[currentQuestion.id];

  bool get isLastQuestion => currentIndex >= attempt.questions.length - 1;

  bool get hasTimer => remainingSeconds != null;

  String get timerDisplay {
    if (remainingSeconds == null) return '';
    final m = remainingSeconds! ~/ 60;
    final s = remainingSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TakeQuizInProgress copyWith({
    int? currentIndex,
    Map<String, Map<String, dynamic>?>? answers,
    int? remainingSeconds,
    bool? isSubmitting,
  }) {
    return TakeQuizInProgress(
      attempt: attempt,
      quizTitle: quizTitle,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        attempt,
        quizTitle,
        currentIndex,
        answers,
        remainingSeconds,
        isSubmitting,
      ];
}

class TakeQuizFinishing extends TakeQuizState {
  const TakeQuizFinishing();
}

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

class TakeQuizSubmitted extends TakeQuizState {
  const TakeQuizSubmitted();
}

class TakeQuizError extends TakeQuizState {
  final String message;
  const TakeQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
