import 'package:equatable/equatable.dart';

abstract class TakeQuizEvent extends Equatable {
  const TakeQuizEvent();
  @override
  List<Object?> get props => [];
}

class StartSessionEvent extends TakeQuizEvent {
  final String quizId;
  final String? resumeSessionId;
  const StartSessionEvent(this.quizId, {this.resumeSessionId});
  @override
  List<Object?> get props => [quizId, resumeSessionId];
}

class SetAnswerEvent extends TakeQuizEvent {
  final dynamic answer;
  const SetAnswerEvent(this.answer);
  @override
  List<Object?> get props => [answer];
}

class SubmitCurrentAnswerEvent extends TakeQuizEvent {
  const SubmitCurrentAnswerEvent();
}

class NextQuestionEvent extends TakeQuizEvent {
  const NextQuestionEvent();
}

class CompleteSessionEvent extends TakeQuizEvent {
  const CompleteSessionEvent();
}

class TimerTickEvent extends TakeQuizEvent {
  final int remainingSeconds;
  const TimerTickEvent(this.remainingSeconds);
  @override
  List<Object?> get props => [remainingSeconds];
}
