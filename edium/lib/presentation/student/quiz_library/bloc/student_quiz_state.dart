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

  const StudentQuizLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
}

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
