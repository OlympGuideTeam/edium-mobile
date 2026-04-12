import 'package:edium/domain/repositories/course_repository.dart';

class CreateModuleUsecase {
  final ICourseRepository _repository;

  CreateModuleUsecase(this._repository);

  Future<void> call({required String courseId, required String title}) =>
      _repository.createModule(courseId: courseId, title: title);
}
