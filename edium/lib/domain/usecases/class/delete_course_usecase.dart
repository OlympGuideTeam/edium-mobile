import 'package:edium/domain/repositories/class_repository.dart';

class DeleteCourseUsecase {
  final IClassRepository _repository;

  DeleteCourseUsecase(this._repository);

  Future<void> call({required String courseId}) =>
      _repository.deleteCourse(courseId: courseId);
}
