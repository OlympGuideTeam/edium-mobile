part of 'take_quiz_event.dart';

class JumpToQuestionEvent extends TakeQuizEvent {
  final int index;
  const JumpToQuestionEvent(this.index);
  @override
  List<Object?> get props => [index];
}

