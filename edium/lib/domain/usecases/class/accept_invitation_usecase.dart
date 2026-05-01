import 'package:edium/domain/repositories/invitation_repository.dart';

class AcceptInvitationUsecase {
  final IInvitationRepository _repository;

  AcceptInvitationUsecase(this._repository);

  Future<String> call({required String invitationId}) =>
      _repository.acceptInvitation(invitationId: invitationId);
}
