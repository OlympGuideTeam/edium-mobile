import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/data/models/quiz_session_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class QuizSessionDatasourceImpl extends BaseApiService
    implements IQuizSessionDatasource {
  QuizSessionDatasourceImpl(super.dio);

  @override
  Future<QuizSessionModel> startSession(String quizId) {
    return request(
      'api/v1/quiz-sessions',
      method: HttpMethod.post,
      req: {'quiz_id': quizId},
      parser: (data) => QuizSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<QuizSessionModel> getSession(String sessionId) {
    return request(
      'api/v1/quiz-sessions/$sessionId',
      method: HttpMethod.get,
      parser: (data) => QuizSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) {
    return request(
      'api/v1/quiz-sessions/$sessionId/answer',
      method: HttpMethod.post,
      req: {'question_id': questionId, 'answer': answer},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  @override
  Future<QuizSessionModel> completeSession(String sessionId) {
    return request(
      'api/v1/quiz-sessions/$sessionId/complete',
      method: HttpMethod.post,
      parser: (data) => QuizSessionModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<QuizSessionModel>> getMySessions() {
    return request(
      'api/v1/users/me/quiz-sessions',
      method: HttpMethod.get,
      parser: (data) => (data as List<dynamic>)
          .map((e) => QuizSessionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
