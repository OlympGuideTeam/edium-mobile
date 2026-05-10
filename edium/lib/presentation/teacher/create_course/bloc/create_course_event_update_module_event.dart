part of 'create_course_event.dart';

class UpdateModuleEvent extends CreateCourseEvent {
  final int index;
  final String title;
  const UpdateModuleEvent(this.index, this.title);
  @override
  List<Object?> get props => [index, title];
}

