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

  /// Если true — bloc сначала проверяет Hive-кэш (Task 2), и при отсутствии
  /// записи вызывает `ITestSessionRepository.startOrResumeAttempt`, что
  /// записывает попытку в кэш. Каждый `SetAnswerEvent` → persist в кэш.
  /// Если false — старый флоу через `CreateAttemptUsecase` (public library).
  final bool useCache;

  const StartAttemptEvent({
    required this.sessionId,
    required this.quizTitle,
    this.totalTimeLimitSec,
    this.useCache = false,
  });

  @override
  List<Object?> get props => [sessionId, quizTitle, totalTimeLimitSec, useCache];
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

/// Прыгнуть к конкретному вопросу (свободная навигация).
class JumpToQuestionEvent extends TakeQuizEvent {
  final int index;
  const JumpToQuestionEvent(this.index);
  @override
  List<Object?> get props => [index];
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
