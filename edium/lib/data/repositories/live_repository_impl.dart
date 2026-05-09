import 'package:edium/data/datasources/live/live_datasource.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';

class LiveRepositoryImpl implements ILiveRepository {
  final ILiveDatasource _datasource;

  const LiveRepositoryImpl(this._datasource);

  @override
  Future<LiveSessionMeta> resolveLiveCode(String code) =>
      _datasource.resolveLiveCode(code);

  @override
  Future<LiveSessionMeta> getLiveSession(String sessionId) =>
      _datasource.getLiveSession(sessionId);

  @override
  Future<LiveStartResult> startLiveSession(String sessionId) =>
      _datasource.startLiveSession(sessionId);

  @override
  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  }) =>
      _datasource.joinLiveSession(sessionId: sessionId, name: name);

  @override
  Future<List<LiveRosterMember>> getModuleRoster(String moduleId) =>
      _datasource.getModuleRoster(moduleId);

  @override
  Future<List<LiveRosterMember>> getUsersRoster(List<String> userIds) =>
      _datasource.getUsersRoster(userIds);

  @override
  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId, String attemptId) =>
      _datasource.getLiveResultsStudent(sessionId, attemptId);

  @override
  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId) =>
      _datasource.getLiveResultsTeacher(sessionId);

  @override
  Future<LiveAttemptReview> getAttemptReview(String attemptId) =>
      _datasource.getAttemptReview(attemptId);

  @override
  Future<List<LiveLibrarySession>> getMyLiveSessions() =>
      _datasource.getMyLiveSessions();

  @override
  Future<String> createLiveLibrarySession(
    String quizTemplateId, {
    int? questionTimeLimitSec,
  }) =>
      _datasource.createLiveLibrarySession(
        quizTemplateId,
        questionTimeLimitSec: questionTimeLimitSec,
      );
}
