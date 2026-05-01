import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/domain/repositories/invitation_repository.dart';

class InvitationRepositoryImpl implements IInvitationRepository {
  final IInvitationDatasource _datasource;

  InvitationRepositoryImpl(this._datasource);

  @override
  Future<void> acceptInvitation({required String invitationId}) =>
      _datasource.acceptInvitation(invitationId: invitationId);
}
