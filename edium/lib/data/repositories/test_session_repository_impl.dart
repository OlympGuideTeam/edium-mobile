import 'package:edium/data/datasources/attempt_cache/attempt_cache_datasource.dart';
import 'package:edium/data/datasources/test_session/test_session_datasource.dart';
import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';

class TestSessionRepositoryImpl implements ITestSessionRepository {
  final ITestSessionDatasource _ds;
  final IAttemptCacheDatasource _cache;

  TestSessionRepositoryImpl({
    required ITestSessionDatasource datasource,
    required IAttemptCacheDatasource cache,
  })  : _ds = datasource,
        _cache = cache;

  @override
  Future<TestSessionMeta> getSessionMeta({
    required String quizId,
    String? sessionIdFallback,
  }) async {
    final m = await _ds.getSessionMetaByQuizId(
      quizId: quizId,
      fallbackSessionId: sessionIdFallback,
    );
    return m.toEntity();
  }

  @override
  Future<StartOrResumeResult> startOrResumeAttempt({
    required String sessionId,
    DateTime? deadline,
  }) async {
    final cached = await _cache.read(sessionId);
    final now = DateTime.now();
    if (cached != null && !cached.isExpired(now)) {
      return StartOrResumeResult(
        attempt: QuizAttempt(
          attemptId: cached.attemptId,
          questions: cached.questions.map((e) => e.toEntity()).toList(),
        ),
        cachedAnswers: cached.answers,
        resumedFromCache: true,
      );
    }

    if (cached != null) {
      await _cache.delete(sessionId);
    }

    final fresh = await _ds.createAttempt(sessionId);
    final entry = AttemptCacheEntry(
      sessionId: sessionId,
      attemptId: fresh.attemptId,
      questions: fresh.questions,
      answers: const {},
      startedAt: now,
      expiresAt: deadline,
    );
    await _cache.write(entry);
    return StartOrResumeResult(
      attempt: fresh.toEntity(),
      cachedAnswers: const {},
      resumedFromCache: false,
    );
  }

  @override
  Future<AttemptCacheEntry?> readCachedAttempt(String sessionId) =>
      _cache.read(sessionId);

  @override
  Future<void> submitAnswer({
    required String attemptId,
    required String sessionId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) async {
    final cached = await _cache.read(sessionId);
    if (cached != null) {
      final updatedAnswers =
          Map<String, Map<String, dynamic>>.from(cached.answers);
      updatedAnswers[questionId] = answerData;
      await _cache.write(cached.copyWith(answers: updatedAnswers));
    }
    try {
      await _ds.submitAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answerData: answerData,
      );
    } catch (_) {

    }
  }

  @override
  Future<void> finishAttempt({
    required String attemptId,
    required String sessionId,
  }) async {

    final cached = await _cache.read(sessionId);
    if (cached != null) {
      for (final entry in cached.answers.entries) {
        try {
          await _ds.submitAnswer(
            attemptId: attemptId,
            questionId: entry.key,
            answerData: entry.value,
          );
        } catch (_) {

        }
      }
    }
    await _ds.finishAttempt(attemptId);
    await _cache.delete(sessionId);
  }

  @override
  Future<List<AttemptSummary>> listSessionAttempts(String sessionId) async {
    final list = await _ds.listSessionAttempts(sessionId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AttemptReview> getAttemptReview(String attemptId) async {
    final r = await _ds.getAttemptReview(attemptId);
    return r.toEntity();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _ds.deleteSession(sessionId);
    await _cache.delete(sessionId);
  }

  @override
  Future<void> gradeAttempt({
    required String attemptId,
    required List<({String submissionId, double score, String? feedback})> grades,
  }) =>
      _ds.gradeAttempt(attemptId: attemptId, grades: grades);

  @override
  Future<void> completeAttempt(String attemptId) =>
      _ds.completeAttempt(attemptId);

  @override
  Future<void> publishSession(String sessionId) =>
      _ds.publishSession(sessionId);

  @override
  Future<void> finishSession(String sessionId) =>
      _ds.finishSession(sessionId);
}
