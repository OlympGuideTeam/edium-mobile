part of 'course_detail_event.dart';

class LoadCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  const LoadCourseDetailEvent(this.courseId);
}

