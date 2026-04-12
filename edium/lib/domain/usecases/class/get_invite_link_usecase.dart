import 'package:edium/domain/repositories/class_repository.dart';

class GetInviteLinkUsecase {
  final IClassRepository _repository;

  GetInviteLinkUsecase(this._repository);

  Future<String> call({required String classId, required String role}) =>
      _repository.getInviteLink(classId: classId, role: role);
}
