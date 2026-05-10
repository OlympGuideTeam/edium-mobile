part of 'create_quiz_event.dart';

class UpdateStartedAtEvent extends CreateQuizEvent {
  final DateTime? dateTime;
  const UpdateStartedAtEvent(this.dateTime);
  @override
  List<Object?> get props => [dateTime];
}

