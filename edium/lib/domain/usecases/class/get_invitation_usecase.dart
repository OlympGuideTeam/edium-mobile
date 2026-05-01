import 'package:edium/domain/entities/invitation_detail.dart';
import 'package:edium/domain/repositories/invitation_repository.dart';

class GetInvitationUsecase {
  final IInvitationRepository _repository;

  GetInvitationUsecase(this._repository);

  Future<InvitationDetail> call({required String invitationId}) =>
      _repository.getInvitation(invitationId: invitationId);
}
