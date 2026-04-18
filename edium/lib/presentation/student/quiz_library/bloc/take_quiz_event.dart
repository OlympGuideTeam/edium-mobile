import 'package:equatable/equatable.dart';

abstract class TakeQuizEvent extends Equatable {
  const TakeQuizEvent();
  @override
  List<Object?> get props => [];
}

class StartAttemptEvent extends TakeQuizEvent {
  final String sessionId;
  final String quizTitle;
  final int? totalTimeLimitSec;

  const StartAttemptEvent({
    required this.sessionId,
    required this.quizTitle,
    this.totalTimeLimitSec,
  });

  @override
  List<Object?> get props => [sessionId, quizTitle, totalTimeLimitSec];
}

class SetAnswerEvent extends TakeQuizEvent {
  final Map<String, dynamic> answerData;
  const SetAnswerEvent(this.answerData);
  @override
  List<Object?> get props => [answerData];
}

class GoNextEvent extends TakeQuizEvent {
  const GoNextEvent();
}

class GoPrevEvent extends TakeQuizEvent {
  const GoPrevEvent();
}

class FinishAttemptEvent extends TakeQuizEvent {
  const FinishAttemptEvent();
}

class TimerTickEvent extends TakeQuizEvent {
  final int remainingSeconds;
  const TimerTickEvent(this.remainingSeconds);
  @override
  List<Object?> get props => [remainingSeconds];
}
