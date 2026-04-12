import 'package:equatable/equatable.dart';

abstract class CreateCourseEvent extends Equatable {
  const CreateCourseEvent();
  @override
  List<Object?> get props => [];
}

class UpdateCourseTitleEvent extends CreateCourseEvent {
  final String title;
  const UpdateCourseTitleEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class AddModuleEvent extends CreateCourseEvent {
  const AddModuleEvent();
}

class UpdateModuleEvent extends CreateCourseEvent {
  final int index;
  final String title;
  const UpdateModuleEvent(this.index, this.title);
  @override
  List<Object?> get props => [index, title];
}

class RemoveModuleEvent extends CreateCourseEvent {
  final int index;
  const RemoveModuleEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitCourseEvent extends CreateCourseEvent {
  final String classId;
  const SubmitCourseEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}
