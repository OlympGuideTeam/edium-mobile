part of 'create_quiz_event.dart';

class UpdateTitleEvent extends CreateQuizEvent {
  final String title;
  const UpdateTitleEvent(this.title);
  @override
  List<Object?> get props => [title];
}

