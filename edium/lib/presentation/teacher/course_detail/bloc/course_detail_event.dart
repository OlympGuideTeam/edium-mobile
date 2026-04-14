abstract class CourseDetailEvent {
  const CourseDetailEvent();
}

class LoadCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  const LoadCourseDetailEvent(this.courseId);
}

class CreateModuleEvent extends CourseDetailEvent {
  final String title;
  const CreateModuleEvent(this.title);
}
