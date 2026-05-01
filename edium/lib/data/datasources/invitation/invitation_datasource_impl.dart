import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class InvitationDatasourceImpl extends BaseApiService implements IInvitationDatasource {
  InvitationDatasourceImpl(super.dio);

  @override
  Future<void> acceptInvitation({required String invitationId}) {
    return request(
      'caesar/v1/invitations/$invitationId/accept',
      method: HttpMethod.post,
      parser: (_) {},
    );
  }
}
