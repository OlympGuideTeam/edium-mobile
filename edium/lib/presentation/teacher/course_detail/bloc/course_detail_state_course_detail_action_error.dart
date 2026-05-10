part of 'course_detail_state.dart';

class CourseDetailActionError extends CourseDetailState {
  final String message;
  final CourseDetail course;
  const CourseDetailActionError(this.message, this.course);
}

