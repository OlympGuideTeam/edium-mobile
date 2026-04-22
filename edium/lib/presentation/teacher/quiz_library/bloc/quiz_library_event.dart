import 'package:equatable/equatable.dart';

abstract class QuizLibraryEvent extends Equatable {
  const QuizLibraryEvent();
  @override
  List<Object?> get props => [];
}

class LoadQuizzesEvent extends QuizLibraryEvent {
  final String scope;
  final String? search;

  const LoadQuizzesEvent({this.scope = 'global', this.search});

  @override
  List<Object?> get props => [scope, search];
}

class SearchChangedEvent extends QuizLibraryEvent {
  final String query;
  const SearchChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class LikeQuizEvent extends QuizLibraryEvent {
  final String quizId;
  const LikeQuizEvent(this.quizId);
  @override
  List<Object?> get props => [quizId];
}

class DeleteQuizEvent extends QuizLibraryEvent {
  final String quizId;
  const DeleteQuizEvent(this.quizId);
  @override
  List<Object?> get props => [quizId];
}
