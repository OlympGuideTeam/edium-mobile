import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class GetModuleDetailUsecase {
  final ICourseRepository _repository;

  GetModuleDetailUsecase(this._repository);

  Future<ModuleDetail> call({required String moduleId}) {
    return _repository.getModuleDetail(moduleId: moduleId);
  }
}
