part of 'create_quiz_event.dart';

class ReplaceQuestionEvent extends CreateQuizEvent {
  final int index;
  final Map<String, dynamic> question;
  const ReplaceQuestionEvent(this.index, this.question);
  @override
  List<Object?> get props => [index, question];
}

