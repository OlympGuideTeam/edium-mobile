part of 'take_quiz_event.dart';

class TimerTickEvent extends TakeQuizEvent {
  final int remainingSeconds;
  const TimerTickEvent(this.remainingSeconds);
  @override
  List<Object?> get props => [remainingSeconds];
}

