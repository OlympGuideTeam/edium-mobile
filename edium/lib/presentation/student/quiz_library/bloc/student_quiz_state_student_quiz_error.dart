part of 'student_quiz_state.dart';

class StudentQuizError extends StudentQuizState {
  final String message;
  const StudentQuizError(this.message);
  @override
  List<Object?> get props => [message];
}

