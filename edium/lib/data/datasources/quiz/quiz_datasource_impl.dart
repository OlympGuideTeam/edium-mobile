import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/models/quiz_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class QuizDatasourceImpl extends BaseApiService implements IQuizDatasource {
  QuizDatasourceImpl(super.dio);

  @override
  Future<List<QuizModel>> getQuizzes({
    String scope = 'global',
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return request(
      'api/v1/quizzes',
      method: HttpMethod.get,
      query: {
        'scope': scope,
        if (search != null) 'search': search,
        'page': page,
        'limit': limit,
      },
      parser: (data) => (data['items'] as List<dynamic>)
          .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<QuizModel> createQuiz({
    required String title,
    required String subject,
    required Map<String, dynamic> settings,
    required List<Map<String, dynamic>> questions,
  }) {
    return request(
      'api/v1/quizzes',
      method: HttpMethod.post,
      req: {
        'title': title,
        'subject': subject,
        'settings': settings,
        'questions': questions,
      },
      parser: (data) => QuizModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<QuizModel> getQuizById(String id) {
    return request(
      'api/v1/quizzes/$id',
      method: HttpMethod.get,
      parser: (data) => QuizModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> likeQuiz(String id) {
    return request(
      'api/v1/quizzes/$id/like',
      method: HttpMethod.post,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  @override
  Future<Map<String, dynamic>> getQuizResults(String id) {
    return request(
      'api/v1/quizzes/$id/results',
      method: HttpMethod.get,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateQuizStatus(String id, String status) {
    return request(
      'api/v1/quizzes/$id',
      method: HttpMethod.patch,
      req: {'status': status},
      parser: (_) {},
    );
  }

  @override
  Future<void> deleteQuiz(String id) {
    return request(
      'api/v1/quizzes/$id',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }
}
