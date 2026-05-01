import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/services/network/api_exception.dart';

class InvitationDatasourceMock implements IInvitationDatasource {
  final Set<String> _accepted = {};

  @override
  Future<void> acceptInvitation({required String invitationId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_accepted.contains(invitationId)) {
      throw const ApiException(
        'Вы уже состоите в этом классе',
        statusCode: 409,
      );
    }
    _accepted.add(invitationId);
  }
}
