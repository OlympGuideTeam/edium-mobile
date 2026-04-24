import 'package:edium/data/datasources/test_session/test_session_datasource.dart';
import 'package:edium/data/models/attempt_review_model.dart';
import 'package:edium/data/models/attempt_summary_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:edium/data/models/test_session_meta_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class TestSessionDatasourceImpl extends BaseApiService
    implements ITestSessionDatasource {
  TestSessionDatasourceImpl(super.dio);

  @override
  Future<TestSessionMetaModel> getSessionMetaByQuizId({
    required String quizId,
    String? fallbackSessionId,
  }) {
    return request(
      'riddler/v1/quizzes/$quizId',
      method: HttpMethod.get,
      query: {'role': 'student'},
      parser: (data) => TestSessionMetaModel.fromStudentQuizJson(
        data as Map<String, dynamic>,
        fallbackSessionId: fallbackSessionId,
      ),
    );
  }

  @override
  Future<QuizAttemptModel> createAttempt(String sessionId) {
    return request(
      'riddler/v1/sessions/$sessionId/attempts',
      method: HttpMethod.post,
      parser: (data) => QuizAttemptModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) {
    return request(
      'riddler/v1/attempts/$attemptId/answers',
      method: HttpMethod.post,
      req: {'question_id': questionId, 'answer_data': answerData},
      parser: (_) {},
    );
  }

  @override
  Future<void> finishAttempt(String attemptId) {
    return request(
      'riddler/v1/attempts/$attemptId/finish',
      method: HttpMethod.post,
      parser: (_) {},
    );
  }

  @override
  Future<List<AttemptSummaryModel>> listSessionAttempts(String sessionId) {
    return request(
      'riddler/v1/sessions/$sessionId/attempts',
      method: HttpMethod.get,
      parser: (data) => (data as List<dynamic>)
          .map((e) =>
              AttemptSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<AttemptReviewModel> getAttemptReview(String attemptId) {
    return request(
      'riddler/v1/attempts/$attemptId/review',
      method: HttpMethod.get,
      parser: (data) =>
          AttemptReviewModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteSession(String sessionId) {
    return request(
      'riddler/v1/sessions/$sessionId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }
}
