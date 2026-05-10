part of 'quiz_library_state.dart';

class QuizLibraryLoaded extends QuizLibraryState {
  final List<Quiz> quizzes;
  final String scope;
  final String? search;

  const QuizLibraryLoaded({
    required this.quizzes,
    required this.scope,
    this.search,
  });

  @override
  List<Object?> get props => [quizzes, scope, search];
}

