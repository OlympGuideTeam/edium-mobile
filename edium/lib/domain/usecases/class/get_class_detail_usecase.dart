import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/repositories/class_repository.dart';

class GetClassDetailUsecase {
  final IClassRepository _repository;

  GetClassDetailUsecase(this._repository);

  Future<ClassDetail> call({required String classId}) =>
      _repository.getClassDetail(classId: classId);
}
