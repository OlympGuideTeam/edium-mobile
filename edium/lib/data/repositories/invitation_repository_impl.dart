import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/domain/entities/invitation_detail.dart';
import 'package:edium/domain/repositories/invitation_repository.dart';

class InvitationRepositoryImpl implements IInvitationRepository {
  final IInvitationDatasource _datasource;

  InvitationRepositoryImpl(this._datasource);

  @override
  Future<InvitationDetail> getInvitation({required String invitationId}) async {
    final model = await _datasource.getInvitation(invitationId: invitationId);
    return model.toEntity();
  }

  @override
  Future<String> acceptInvitation({required String invitationId}) =>
      _datasource.acceptInvitation(invitationId: invitationId);
}
