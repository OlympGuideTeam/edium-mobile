part of 'teacher_grade_event.dart';

class SubmitGradesEvent extends TeacherGradeEvent {
  final String attemptId;
  final List<SubmissionGrade> grades;

  const SubmitGradesEvent({required this.attemptId, required this.grades});

  @override
  List<Object?> get props => [attemptId, grades];
}

