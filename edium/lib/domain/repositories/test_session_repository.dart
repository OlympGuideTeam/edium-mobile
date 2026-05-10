import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/entities/test_session_meta.dart';

part 'test_session_repository_start_or_resume_result.dart';


abstract class ITestSessionRepository {
  Future<TestSessionMeta> getSessionMeta({
    required String quizId,
    String? sessionIdFallback,
  });


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

