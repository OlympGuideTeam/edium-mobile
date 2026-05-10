part of 'create_quiz_event.dart';

class SetQuizTypeEvent extends CreateQuizEvent {
  final QuizCreationMode quizType;
  const SetQuizTypeEvent(this.quizType);
  @override
  List<Object?> get props => [quizType];
}

