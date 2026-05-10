part of 'create_quiz_event.dart';

class UpdateQuestionTimeLimitEvent extends CreateQuizEvent {
  final int? seconds;
  const UpdateQuestionTimeLimitEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

