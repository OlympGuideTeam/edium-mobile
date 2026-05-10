part of 'create_quiz_event.dart';

class UpdateDescriptionEvent extends CreateQuizEvent {
  final String description;
  const UpdateDescriptionEvent(this.description);
  @override
  List<Object?> get props => [description];
}

