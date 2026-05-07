import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/entities/test_session_meta.dart';

abstract class ITestSessionRepository {
  Future<TestSessionMeta> getSessionMeta({
    required String quizId,
    String? sessionIdFallback,
  });

  /// Либо восстанавливает не просроченный attempt из Hive-кэша,
  /// либо делает `POST /sessions/:sid/attempts` и пишет в кэш.
  Future<StartOrResumeResult> startOrResumeAttempt({
    required String sessionId,
    DateTime? deadline,
  });

  Future<AttemptCacheEntry?> readCachedAttempt(String sessionId);

  Future<void> submitAnswer({
    required String attemptId,
    required String sessionId,
    required String questionId,
    required Map<String, dynamic> answerData,
  });

  Future<void> finishAttempt({
    required String attemptId,
    required String sessionId,
  });

  Future<List<AttemptSummary>> listSessionAttempts(String sessionId);

  Future<AttemptReview> getAttemptReview(String attemptId);

  Future<void> deleteSession(String sessionId);

  Future<void> gradeAttempt({
    required String attemptId,
    required List<({String submissionId, double score, String? feedback})> grades,
  });

  Future<void> completeAttempt(String attemptId);

  Future<void> publishSession(String sessionId);

  Future<void> finishSession(String sessionId);
}

class StartOrResumeResult {
  final QuizAttempt attempt;
  final Map<String, Map<String, dynamic>> cachedAnswers;
  final bool resumedFromCache;

  const StartOrResumeResult({
    required this.attempt,
    required this.cachedAnswers,
    required this.resumedFromCache,
  });
}
