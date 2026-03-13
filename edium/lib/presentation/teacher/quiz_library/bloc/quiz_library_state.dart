import 'package:edium/domain/entities/quiz.dart';
import 'package:equatable/equatable.dart';

abstract class QuizLibraryState extends Equatable {
  const QuizLibraryState();
  @override
  List<Object?> get props => [];
}

class QuizLibraryInitial extends QuizLibraryState {
  const QuizLibraryInitial();
}

class QuizLibraryLoading extends QuizLibraryState {
  const QuizLibraryLoading();
}

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

class QuizLibraryError extends QuizLibraryState {
  final String message;
  const QuizLibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
