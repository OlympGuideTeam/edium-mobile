part of 'teacher_grade_event.dart';

class LoadTeacherGradeEvent extends TeacherGradeEvent {
  final String attemptId;
  const LoadTeacherGradeEvent(this.attemptId);
  @override
  List<Object?> get props => [attemptId];
}

