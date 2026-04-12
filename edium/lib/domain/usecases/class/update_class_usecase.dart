import 'package:edium/domain/repositories/class_repository.dart';

class UpdateClassUsecase {
  final IClassRepository _repository;

  UpdateClassUsecase(this._repository);

  Future<void> call({required String classId, required String title}) =>
      _repository.updateClass(classId: classId, title: title);
}
