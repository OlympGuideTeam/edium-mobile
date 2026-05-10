import 'package:edium/data/models/attempt_review_model.dart';
import 'package:edium/data/models/attempt_summary_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:edium/data/models/test_session_meta_model.dart';

abstract class ITestSessionDatasource {


  Future<TestSessionMetaModel> getSessionMetaByQuizId({
    required String quizId,
    String? fallbackSessionId,
  });


  Future<QuizAttemptModel> createAttempt(String sessionId);


  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  });


  Future<void> finishAttempt(String attemptId);


  Future<List<AttemptSummaryModel>> listSessionAttempts(String sessionId);


  Future<AttemptReviewModel> getAttemptReview(String attemptId);


  Future<void> deleteSession(String sessionId);


  Future<void> gradeAttempt({
    required String attemptId,
    required List<({String submissionId, double score, String? feedback})> grades,
  });


  Future<void> completeAttempt(String attemptId);


  Future<void> publishSession(String sessionId);


  Future<void> finishSession(String sessionId);
}
