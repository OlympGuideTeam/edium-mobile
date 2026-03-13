import 'package:edium/domain/entities/quiz.dart';
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
  final List<Quiz> quizzes;
  final Map<String, ({int score, int total})> completedSessions;
  final Map<String, String> inProgressSessions; // quizId → sessionId

  const StudentQuizLoaded(
    this.quizzes,
    this.completedSessions,
    this.inProgressSessions,
  );

  @override
  List<Object?> get props =>
      [quizzes, completedSessions, inProgressSessions];
}

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
  @override
  List<Object?> get props => [message];
}
