import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

abstract interface class ILiveDatasource {
  Future<LiveSessionMeta> resolveLiveCode(String code);
  Future<LiveSessionMeta> getLiveSession(String sessionId);
  Future<LiveStartResult> startLiveSession(String sessionId);
  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  });
  Future<List<LiveRosterMember>> getModuleRoster(String moduleId);
  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId);
  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId);
}
