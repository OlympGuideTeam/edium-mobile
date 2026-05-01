import 'package:edium/data/datasources/invitation/invitation_datasource.dart';
import 'package:edium/data/models/invitation_detail_model.dart';
import 'package:edium/services/network/api_exception.dart';

class InvitationDatasourceMock implements IInvitationDatasource {
  final Set<String> _accepted = {};

  @override
  Future<InvitationDetailModel> getInvitation({required String invitationId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const InvitationDetailModel(
      classTitle: '10А — Математика',
      studentCount: 28,
      role: 'student',
    );
  }

  @override
  Future<String> acceptInvitation({required String invitationId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_accepted.contains(invitationId)) {
      throw const ApiException('Вы уже состоите в этом классе', statusCode: 409);
    }
    _accepted.add(invitationId);
    return 'mock-class-0001';
  }
}
