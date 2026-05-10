part of 'create_course_event.dart';

class UpdateCourseTitleEvent extends CreateCourseEvent {
  final String title;
  const UpdateCourseTitleEvent(this.title);
  @override
  List<Object?> get props => [title];
}

