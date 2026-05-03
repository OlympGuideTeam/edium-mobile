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
  final String searchQuery;

  const StudentQuizLoaded({
    required this.quizzes,
    required this.filtered,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [quizzes, filtered, searchQuery];
}

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
