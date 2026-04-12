import 'package:edium/domain/repositories/class_repository.dart';

class RemoveMemberUsecase {
  final IClassRepository _repository;

  RemoveMemberUsecase(this._repository);

  Future<void> call({required String classId, required String userId}) =>
      _repository.removeMember(classId: classId, userId: userId);
}
