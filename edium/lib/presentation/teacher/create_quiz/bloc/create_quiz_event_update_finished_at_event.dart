part of 'create_quiz_event.dart';

class UpdateFinishedAtEvent extends CreateQuizEvent {
  final DateTime? dateTime;
  const UpdateFinishedAtEvent(this.dateTime);
  @override
  List<Object?> get props => [dateTime];
}

