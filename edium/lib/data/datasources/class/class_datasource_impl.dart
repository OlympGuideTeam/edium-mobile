import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/data/models/class_detail_model.dart';
import 'package:edium/data/models/class_summary_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class ClassDatasourceImpl extends BaseApiService implements IClassDatasource {
  ClassDatasourceImpl(super.dio);

  @override
  Future<String> createClass({required String title}) {
    return request(
      'caesar/v1/classes',
      method: HttpMethod.post,
      req: {'title': title},
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  @override
  Future<List<ClassSummaryModel>> getMyClasses({required String role}) {
    return request(
      'caesar/v1/classes/me',
      method: HttpMethod.get,
      query: {'role': role},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['classes'] as List<dynamic>;
        return list
            .map((e) =>
                ClassSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<ClassDetailModel> getClassDetail({required String classId}) {
    return request(
      'caesar/v1/classes/$classId',
      method: HttpMethod.get,
      parser: (data) =>
          ClassDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> updateClass({
    required String classId,
    required String title,
  }) {
    return request(
      'caesar/v1/classes/$classId',
      method: HttpMethod.patch,
      req: {'title': title},
      parser: (_) {},
    );
  }

  @override
  Future<void> deleteClass({required String classId}) {
    return request(
      'caesar/v1/classes/$classId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<void> removeMember({
    required String classId,
    required String userId,
  }) {
    return request(
      'caesar/v1/classes/$classId/members/$userId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<String> getInviteLink({
    required String classId,
    required String role,
  }) {
    return request(
      'caesar/v1/classes/$classId/invite',
      method: HttpMethod.get,
      query: {'role': role},
      parser: (data) {
        final map = data as Map<String, dynamic>?;
        final invitationId = map?['invitation_id'] as String?;
        if (invitationId == null || invitationId.isEmpty) {
          throw Exception('Сервер не вернул идентификатор приглашения');
        }
        return 'https://links.edium.online/invite/$invitationId';
      },
    );
  }

  @override
  Future<void> deleteCourse({required String courseId}) {
    return request(
      'caesar/v1/courses/$courseId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }
}
