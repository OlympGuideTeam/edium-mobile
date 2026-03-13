import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/entities/quiz_session.dart';
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
  final Quiz quiz;
  final QuizSession session;
  final int currentIndex;
  final dynamic currentAnswer;
  final bool answerSubmitted;
  final bool? lastCorrect;
  final String? lastExplanation;
  final int? remainingSeconds;

  const TakeQuizInProgress({
    required this.quiz,
    required this.session,
    required this.currentIndex,
    this.currentAnswer,
    this.answerSubmitted = false,
    this.lastCorrect,
    this.lastExplanation,
    this.remainingSeconds,
  });

  bool get isLastQuestion => currentIndex >= quiz.questions.length - 1;

  bool get hasTimer => remainingSeconds != null;

  String get timerDisplay {
    if (remainingSeconds == null) return '';
    final m = remainingSeconds! ~/ 60;
    final s = remainingSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TakeQuizInProgress copyWith({
    Quiz? quiz,
    QuizSession? session,
    int? currentIndex,
    dynamic currentAnswer,
    bool? answerSubmitted,
    bool? lastCorrect,
    String? lastExplanation,
    int? remainingSeconds,
  }) {
    return TakeQuizInProgress(
      quiz: quiz ?? this.quiz,
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      currentAnswer: currentAnswer,
      answerSubmitted: answerSubmitted ?? this.answerSubmitted,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      lastExplanation: lastExplanation ?? this.lastExplanation,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        quiz,
        session,
        currentIndex,
        currentAnswer,
        answerSubmitted,
        lastCorrect,
        lastExplanation,
        remainingSeconds,
      ];
}

class TakeQuizCompleted extends TakeQuizState {
  final QuizSession result;

  const TakeQuizCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

class TakeQuizError extends TakeQuizState {
  final String message;
  const TakeQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
