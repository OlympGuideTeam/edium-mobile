part of 'create_course_event.dart';

class ReorderModulesEvent extends CreateCourseEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderModulesEvent(this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

