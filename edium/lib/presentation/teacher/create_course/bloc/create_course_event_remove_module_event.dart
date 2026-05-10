part of 'create_course_event.dart';

class RemoveModuleEvent extends CreateCourseEvent {
  final int index;
  const RemoveModuleEvent(this.index);
  @override
  List<Object?> get props => [index];
}

