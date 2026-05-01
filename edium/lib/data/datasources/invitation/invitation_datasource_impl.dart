import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/data/models/invitation_detail_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class InvitationDatasourceImpl extends BaseApiService implements IInvitationDatasource {
  InvitationDatasourceImpl(super.dio);

  @override
  Future<InvitationDetailModel> getInvitation({required String invitationId}) {
    return request(
      'caesar/v1/invitations/$invitationId',
      method: HttpMethod.get,
      parser: (json) => InvitationDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<String> acceptInvitation({required String invitationId}) {
    return request(
      'caesar/v1/invitations/$invitationId/accept',
      method: HttpMethod.post,
      parser: (json) => (json as Map<String, dynamic>)['class_id'] as String,
    );
  }
}
