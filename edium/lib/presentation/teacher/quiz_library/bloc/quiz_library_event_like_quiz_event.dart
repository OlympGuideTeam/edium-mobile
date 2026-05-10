part of 'quiz_library_event.dart';

class LikeQuizEvent extends QuizLibraryEvent {
  final String quizId;
  const LikeQuizEvent(this.quizId);
  @override
  List<Object?> get props => [quizId];
}

