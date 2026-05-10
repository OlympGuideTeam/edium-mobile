part of 'create_quiz_event.dart';

class AddQuestionEvent extends CreateQuizEvent {
  final Map<String, dynamic> question;
  const AddQuestionEvent(this.question);
  @override
  List<Object?> get props => [question];
}

