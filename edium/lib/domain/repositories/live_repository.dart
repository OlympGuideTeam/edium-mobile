import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

abstract interface class ILiveRepository {
  /// Resolve 6-digit code → session meta (no auth required).
  Future<LiveSessionMeta> resolveLiveCode(String code);

  /// GET meta of a session by sessionId.
  Future<LiveSessionMeta> getLiveSession(String sessionId);

  /// Open lobby + get ws_token for teacher (POST /live/start).
  Future<LiveStartResult> startLiveSession(String sessionId);

  /// Join lobby — creates attempt, returns attempt_id + ws_token.
  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  });

  /// Список учеников класса для модуля (Caesar) — предзагрузка имён в лобби live.
  Future<List<LiveRosterMember>> getModuleRoster(String moduleId);

  /// Final results for student.
  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId, String attemptId);

  /// Final results for teacher.
  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId);

  /// Per-question review for student (answers + scores).
  Future<LiveAttemptReview> getAttemptReview(String attemptId);

  /// Список лайв-сессий текущего учителя из библиотеки.
  Future<List<LiveLibrarySession>> getMyLiveSessions();

  /// Создать library live-сессию по шаблону квиза (POST /sessions/live/library).
  Future<String> createLiveLibrarySession(
    String quizTemplateId, {
    int? questionTimeLimitSec,
  });
}
