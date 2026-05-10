part of 'teacher_grade_state.dart';

class TeacherGradeError extends TeacherGradeState {
  final String message;
  const TeacherGradeError(this.message);
  @override
  List<Object?> get props => [message];
}

