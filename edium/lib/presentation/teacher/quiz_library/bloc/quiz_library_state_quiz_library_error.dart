part of 'quiz_library_state.dart';

class QuizLibraryError extends QuizLibraryState {
  final String message;
  const QuizLibraryError(this.message);
  @override
  List<Object?> get props => [message];
}

