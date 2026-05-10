part of 'take_quiz_event.dart';

class StartAttemptEvent extends TakeQuizEvent {
  final String sessionId;
  final String quizTitle;
  final int? totalTimeLimitSec;


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

