import 'package:equatable/equatable.dart';

abstract class StudentQuizEvent extends Equatable {
  const StudentQuizEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudentQuizzesEvent extends StudentQuizEvent {
  const LoadStudentQuizzesEvent();
}

class StudentSearchChangedEvent extends StudentQuizEvent {
  final String query;
  const StudentSearchChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}
