import 'package:edium/data/models/invitation_detail_model.dart';

abstract class IInvitationDatasource {
  Future<InvitationDetailModel> getInvitation({required String invitationId});
  Future<String> acceptInvitation({required String invitationId});
}
