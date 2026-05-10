part of 'quiz_library_event.dart';

class DeleteQuizEvent extends QuizLibraryEvent {
  final String quizId;
  const DeleteQuizEvent(this.quizId);
  @override
  List<Object?> get props => [quizId];
}

