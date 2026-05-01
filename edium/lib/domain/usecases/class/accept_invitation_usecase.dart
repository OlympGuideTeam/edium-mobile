import 'package:edium/domain/repositories/invitation_repository.dart';

class AcceptInvitationUsecase {
  final IInvitationRepository _repository;

  AcceptInvitationUsecase(this._repository);

  Future<void> call({required String invitationId}) =>
      _repository.acceptInvitation(invitationId: invitationId);
}
