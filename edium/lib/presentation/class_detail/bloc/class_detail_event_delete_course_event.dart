part of 'class_detail_event.dart';

class DeleteCourseEvent extends ClassDetailEvent {
  final String courseId;
  const DeleteCourseEvent(this.courseId);
}

