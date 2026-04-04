import 'package:edium/domain/repositories/class_repository.dart';

class CreateClassUsecase {
  final IClassRepository _repository;

  CreateClassUsecase(this._repository);

  Future<String> call({required String title}) =>
      _repository.createClass(title: title);
}
