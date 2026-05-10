part of 'take_quiz_event.dart';

class SetAnswerEvent extends TakeQuizEvent {
  final Map<String, dynamic> answerData;
  const SetAnswerEvent(this.answerData);
  @override
  List<Object?> get props => [answerData];
}

