part of 'teacher_grade_event.dart';

class CompleteGradingEvent extends TeacherGradeEvent {
  final String attemptId;
  const CompleteGradingEvent(this.attemptId);
  @override
  List<Object?> get props => [attemptId];
}

