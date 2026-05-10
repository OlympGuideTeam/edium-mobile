part of 'course_detail_event.dart';

class SilentReloadCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  const SilentReloadCourseDetailEvent(this.courseId);
}

