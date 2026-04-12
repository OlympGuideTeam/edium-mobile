import 'package:edium/domain/repositories/class_repository.dart';

class DeleteClassUsecase {
  final IClassRepository _repository;

  DeleteClassUsecase(this._repository);

  Future<void> call({required String classId}) =>
      _repository.deleteClass(classId: classId);
}
