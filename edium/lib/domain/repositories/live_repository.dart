import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

abstract interface class ILiveRepository {

  Future<LiveSessionMeta> resolveLiveCode(String code);


  Future<LiveSessionMeta> getLiveSession(String sessionId);


  Future<LiveStartResult> startLiveSession(String sessionId);


  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  });


  Future<List<LiveRosterMember>> getModuleRoster(String moduleId);


  Future<List<LiveRosterMember>> getUsersRoster(List<String> userIds);


  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId, String attemptId);


  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId);


  Future<LiveAttemptReview> getAttemptReview(String attemptId);


  Future<List<LiveLibrarySession>> getMyLiveSessions();


  Future<String> createLiveLibrarySession(
    String quizTemplateId, {
    int? questionTimeLimitSec,
  });
}
