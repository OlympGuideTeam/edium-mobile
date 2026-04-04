import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/repositories/class_repository.dart';

class GetMyClassesUsecase {
  final IClassRepository _repository;

  GetMyClassesUsecase(this._repository);

  Future<List<ClassSummary>> call({required String role}) =>
      _repository.getMyClasses(role: role);
}
