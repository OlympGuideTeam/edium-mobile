import 'package:equatable/equatable.dart';

abstract class StudentQuizEvent extends Equatable {
  const StudentQuizEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudentQuizzesEvent extends StudentQuizEvent {
  final String? search;
  const LoadStudentQuizzesEvent({this.search});
  @override
  List<Object?> get props => [search];
}

class StudentSearchChangedEvent extends StudentQuizEvent {
  final String query;
  const StudentSearchChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class StudentLikeQuizEvent extends StudentQuizEvent {
  final String quizId;
  const StudentLikeQuizEvent(this.quizId);
  @override
  List<Object?> get props => [quizId];
}
