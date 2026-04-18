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
  }) async {
    if (scope == 'mine') {
      final list = await request<List<QuizModel>>(
        'riddler/v1/quizzes/my',
        method: HttpMethod.get,
        parser: (data) => (data as List<dynamic>)
            .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      final q = search?.trim().toLowerCase();
      if (q == null || q.isEmpty) return list;
      return list
          .where((quiz) => quiz.title.toLowerCase().contains(q))
          .toList();
    }

    return request(
      'riddler/v1/quizzes',
      method: HttpMethod.get,
      query: {
        'role': 'teacher',
        if (search != null && search.trim().isNotEmpty) 'search': search,
      },
      parser: (data) => (data as List<dynamic>)
          .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<String> createQuiz({
    required String title,
    String? description,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    required List<Map<String, dynamic>> questions,
  }) async {
    final id = await request<String>(
      'riddler/v1/quizzes',
      method: HttpMethod.post,
      req: {
        'title': title,
        if (description != null) 'description': description,
        'default_settings': {
          if (totalTimeLimitSec != null)
            'total_time_limit_sec': totalTimeLimitSec,
          if (questionTimeLimitSec != null)
            'question_time_limit_sec': questionTimeLimitSec,
          'shuffle_questions': shuffleQuestions,
        },
      },
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );

    for (final q in questions) {
      await request<void>(
        'riddler/v1/quizzes/$id/questions',
        method: HttpMethod.post,
        req: q,
        parser: (_) {},
      );
    }

    return id;
  }

  @override
  Future<QuizModel> getQuizById(String id) {
    return request(
      'riddler/v1/quizzes/$id',
      method: HttpMethod.get,
      query: {'role': 'teacher'},
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
  Future<void> publishQuiz(String id, {required bool isPublic}) {
    return request(
      'riddler/v1/quizzes/$id/publish',
      method: HttpMethod.post,
      req: {'is_public': isPublic},
      parser: (_) {},
    );
  }

  @override
  Future<String> copyQuiz(String id) {
    return request(
      'riddler/v1/quizzes/$id/copy',
      method: HttpMethod.post,
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  @override
  Future<void> deleteQuiz(String id) {
    return request(
      'riddler/v1/quizzes/$id',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }
}
