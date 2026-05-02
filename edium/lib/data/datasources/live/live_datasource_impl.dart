import 'package:edium/data/datasources/live/live_datasource.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class LiveDatasourceImpl extends BaseApiService implements ILiveDatasource {
  LiveDatasourceImpl(super.dio);

  @override
  Future<LiveSessionMeta> resolveLiveCode(String code) => request(
        'riddler/v1/sessions/live/$code',
        method: HttpMethod.get,
        parser: (data) =>
            LiveSessionMeta.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<LiveSessionMeta> getLiveSession(String sessionId) => request(
        'riddler/v1/sessions/$sessionId/live',
        method: HttpMethod.get,
        parser: (data) =>
            LiveSessionMeta.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<LiveStartResult> startLiveSession(String sessionId) => request(
        'riddler/v1/sessions/$sessionId/live/start',
        method: HttpMethod.post,
        parser: (data) =>
            LiveStartResult.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  }) =>
      request(
        'riddler/v1/sessions/$sessionId/live/join',
        method: HttpMethod.post,
        req: name != null ? {'name': name} : null,
        parser: (data) =>
            LiveJoinResult.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<List<LiveRosterMember>> getModuleRoster(String moduleId) => request(
        'caesar/v1/modules/$moduleId/roster',
        method: HttpMethod.get,
        parser: (data) {
          final members =
              (data as Map<String, dynamic>)['members'] as List<dynamic>? ?? [];
          return members
              .map((e) => LiveRosterMember.fromModuleRosterMemberJson(
                    e as Map<String, dynamic>,
                  ))
              .where((m) => m.userId.isNotEmpty)
              .toList();
        },
      );

  @override
  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId) => request(
        'riddler/v1/sessions/$sessionId/live/results/student',
        method: HttpMethod.get,
        parser: (data) =>
            LiveResultsStudent.fromJson(data as Map<String, dynamic>),
      );

  @override
  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId) => request(
        'riddler/v1/sessions/$sessionId/live/results/teacher',
        method: HttpMethod.get,
        parser: (data) =>
            LiveResultsTeacher.fromJson(data as Map<String, dynamic>),
      );
}
