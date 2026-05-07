import 'package:edium/data/models/attempt_review_model.dart';
import 'package:edium/data/models/attempt_summary_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:edium/data/models/test_session_meta_model.dart';

abstract class ITestSessionDatasource {
  /// `GET /quizzes/:quizId?role=student`. Возвращает meta — для course-теста
  /// sessionId нужно передать отдельно ([fallbackSessionId]), для public library
  /// возьмётся из `library_test_session_id`.
  Future<TestSessionMetaModel> getSessionMetaByQuizId({
    required String quizId,
    String? fallbackSessionId,
  });

  /// `POST /sessions/:sessionId/attempts`. Создаёт попытку; 409 если уже есть.
  Future<QuizAttemptModel> createAttempt(String sessionId);

  /// `POST /attempts/:attemptId/answers`. Upsert.
  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  });

  /// `POST /attempts/:attemptId/finish`.
  Future<void> finishAttempt(String attemptId);

  /// `GET /sessions/:sessionId/attempts`. Только для учителя-автора.
  /// NB: в spec Riddler этот endpoint описан в блоке
  /// `/attempts/{attempt_id}/finish`-GET с path-параметром `session_id` —
  /// это баг spec, фактически используем `/sessions/:sid/attempts`.
  Future<List<AttemptSummaryModel>> listSessionAttempts(String sessionId);

  /// `GET /attempts/:attemptId/review`. Для student (без options/metadata)
  /// и teacher (с options/metadata).
  Future<AttemptReviewModel> getAttemptReview(String attemptId);

  /// `DELETE /sessions/:sessionId`. 409 если есть попытки.
  Future<void> deleteSession(String sessionId);

  /// `POST /attempts/:attemptId/submissions/:submissionId/grade`
  Future<void> gradeSubmission({
    required String attemptId,
    required String submissionId,
    required double score,
    String? feedback,
  });

  /// `POST /attempts/:attemptId/complete`
  Future<void> completeAttempt(String attemptId);

  /// `POST /attempts/session/:sessionId/publish`
  Future<void> publishSession(String sessionId);

  /// `POST /sessions/:sessionId/finish` — досрочное завершение учителем.
  Future<void> finishSession(String sessionId);
}
