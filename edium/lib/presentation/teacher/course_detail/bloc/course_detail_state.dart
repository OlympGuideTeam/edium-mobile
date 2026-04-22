import 'package:edium/domain/entities/course_detail.dart';

abstract class CourseDetailState {
  const CourseDetailState();
}

class CourseDetailInitial extends CourseDetailState {
  const CourseDetailInitial();
}

class CourseDetailLoading extends CourseDetailState {
  const CourseDetailLoading();
}

class CourseDetailLoaded extends CourseDetailState {
  final CourseDetail course;
  const CourseDetailLoaded(this.course);
}

class CourseDetailError extends CourseDetailState {
  final String message;
  const CourseDetailError(this.message);
}

class CourseModuleCreated extends CourseDetailState {
  final CourseDetail course;
  const CourseModuleCreated(this.course);
}

class CourseDetailActionError extends CourseDetailState {
  final String message;
  final CourseDetail course;
  const CourseDetailActionError(this.message, this.course);
}

class CourseDraftDeleted extends CourseDetailState {
  final CourseDetail course;
  const CourseDraftDeleted(this.course);
}
