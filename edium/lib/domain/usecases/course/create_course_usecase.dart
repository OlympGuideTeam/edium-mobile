import 'package:edium/domain/repositories/course_repository.dart';

class CreateCourseUsecase {
  final ICourseRepository _repository;

  CreateCourseUsecase(this._repository);

  Future<String> call({required String title, required String classId}) =>
      _repository.createCourse(title: title, classId: classId);
}
