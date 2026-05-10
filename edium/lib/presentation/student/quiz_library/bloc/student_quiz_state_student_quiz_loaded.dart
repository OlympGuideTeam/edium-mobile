part of 'student_quiz_state.dart';

class StudentQuizLoaded extends StudentQuizState {
  final List<LibraryQuiz> quizzes;
  final List<LibraryQuiz> filtered;
  final List<LibraryQuiz> passedQuizzes;
  final List<LibraryQuiz> filteredPassed;
  final String searchQuery;

  const StudentQuizLoaded({
    required this.quizzes,
    required this.filtered,
    required this.passedQuizzes,
    required this.filteredPassed,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props =>
      [quizzes, filtered, passedQuizzes, filteredPassed, searchQuery];
}

