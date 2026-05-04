import 'package:edium/data/datasources/live/live_datasource.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

class LiveDatasourceMock implements ILiveDatasource {
  @override
  Future<LiveSessionMeta> getLiveSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (sessionId == 'quiz-uuid-0006') {
      return const LiveSessionMeta(
        sessionId: 'quiz-uuid-0006',
        quizTemplateId: 'tpl-0006',
        quizTitle: 'Понятие функции',
        questionCount: 8,
        source: 'course',
        phase: LivePhase.lobby,
        joinCode: '482013',
        questionTimeLimitSec: 30,
        isAnonymousAllowed: false,
        participantsCount: 3,
        moduleId: 'module-3',
      );
    }
    throw Exception('Session not found');
  }

  @override
  Future<LiveSessionMeta> resolveLiveCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (code == '482013') {
      return getLiveSession('quiz-uuid-0006');
    }
    throw Exception('Invalid code');
  }

  @override
  Future<LiveStartResult> startLiveSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const LiveStartResult(wsToken: 'mock-ws-token', joinCode: '482013');
  }

  @override
  Future<LiveJoinResult> joinLiveSession({
    required String sessionId,
    String? name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const LiveJoinResult(
      attemptId: 'mock-attempt-001',
      wsToken: 'mock-ws-token-student',
      moduleId: 'module-3',
    );
  }

  @override
  Future<List<LiveRosterMember>> getModuleRoster(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      LiveRosterMember(userId: 'user-001', name: 'Иван Иванов'),
      LiveRosterMember(userId: 'user-002', name: 'Мария Петрова'),
      LiveRosterMember(userId: 'user-003', name: 'Алексей Сидоров'),
    ];
  }

  @override
  Future<LiveResultsStudent> getLiveResultsStudent(String sessionId, String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const LiveResultsStudent(
      myPosition: 1,
      totalParticipants: 3,
      myScore: 80,
      maxScore: 100,
      correctCount: 6,
      questionsCount: 8,
      top: [],
    );
  }

  @override
  Future<LiveResultsTeacher> getLiveResultsTeacher(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const LiveResultsTeacher(questions: [], leaderboard: []);
  }

  @override
  Future<LiveAttemptReview> getAttemptReview(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return LiveAttemptReview(
      attemptId: attemptId,
      status: 'completed',
      score: 80,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      finishedAt: DateTime.now(),
      answers: [],
    );
  }

  @override
  Future<List<LiveLibrarySession>> getMyLiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  @override
  Future<String> createLiveLibrarySession(
    String quizTemplateId, {
    int? questionTimeLimitSec,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'mock-session-${DateTime.now().millisecondsSinceEpoch}';
  }
}
