part of 'create_quiz_event.dart';

class RemoveQuestionEvent extends CreateQuizEvent {
  final int index;
  const RemoveQuestionEvent(this.index);
  @override
  List<Object?> get props => [index];
}

