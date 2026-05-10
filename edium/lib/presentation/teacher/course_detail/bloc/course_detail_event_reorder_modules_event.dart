part of 'course_detail_event.dart';

class ReorderModulesEvent extends CourseDetailEvent {
  final List<String> moduleIds;
  const ReorderModulesEvent(this.moduleIds);
}

