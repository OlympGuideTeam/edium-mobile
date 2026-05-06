import 'package:edium/domain/entities/library_quiz.dart';
import 'package:equatable/equatable.dart';

abstract class StudentQuizState extends Equatable {
  const StudentQuizState();
  @override
  List<Object?> get props => [];
}

class StudentQuizInitial extends StudentQuizState {
  const StudentQuizInitial();
}

class StudentQuizLoading extends StudentQuizState {
  const StudentQuizLoading();
}

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

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
