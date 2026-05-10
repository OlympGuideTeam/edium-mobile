part of 'create_course_event.dart';

class SubmitCourseEvent extends CreateCourseEvent {
  final String classId;
  const SubmitCourseEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

