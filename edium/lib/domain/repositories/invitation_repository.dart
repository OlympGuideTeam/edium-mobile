import 'package:edium/domain/entities/invitation_detail.dart';

abstract class IInvitationRepository {
  Future<InvitationDetail> getInvitation({required String invitationId});
  Future<String> acceptInvitation({required String invitationId});
}
