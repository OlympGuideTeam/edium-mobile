part of 'create_quiz_event.dart';

class UpdateTotalTimeLimitEvent extends CreateQuizEvent {
  final int? seconds;
  const UpdateTotalTimeLimitEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

