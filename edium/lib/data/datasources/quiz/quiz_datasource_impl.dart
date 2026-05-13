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
      return request<List<QuizModel>>(
        'riddler/v1/quizzes/my',
        method: HttpMethod.get,
        query: {
          if (search != null && search.trim().isNotEmpty) 'search': search,
        },
        parser: (data) => (data as List<dynamic>)
            .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
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
  Future<String> createTestSession({
    required String quizTemplateId,
    required String moduleId,
    int? totalTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return request<String>(
      'riddler/v1/sessions/test',
      method: HttpMethod.post,
      req: {
        'quiz_template_id': quizTemplateId,
        'module_id': moduleId,
        if (totalTimeLimitSec != null) 'total_time_limit_sec': totalTimeLimitSec,
        if (shuffleQuestions) 'shuffle_questions': shuffleQuestions,
        if (startedAt != null) 'started_at': startedAt.toUtc().toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt.toUtc().toIso8601String(),
      },
      parser: (data) => (data as Map<String, dynamic>)['session_id'] as String,
    );
  }

  @override
  Future<String> createLiveSession({
    required String quizTemplateId,
    required String moduleId,
    int? questionTimeLimitSec,
  }) {
    return request<String>(
      'riddler/v1/sessions/live/course',
      method: HttpMethod.post,
      req: {
        'quiz_template_id': quizTemplateId,
        'module_id': moduleId,
        if (questionTimeLimitSec != null)
          'question_time_limit_sec': questionTimeLimitSec,
      },
      parser: (data) => (data as Map<String, dynamic>)['session_id'] as String,
    );
  }

  @override
  Future<String> createQuiz({
    required String title,
    String? description,
    String? mode,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
    required List<Map<String, dynamic>> questions,
    String? courseId,
  }) async {
    final id = await request<String>(
      'riddler/v1/quizzes',
      method: HttpMethod.post,
      req: {
        'title': title,
        if (description != null) 'description': description,
        'default_settings': {
          if (mode != null) 'mode': mode,
          if (totalTimeLimitSec != null)
            'total_time_limit_sec': totalTimeLimitSec,
          if (questionTimeLimitSec != null)
            'question_time_limit_sec': questionTimeLimitSec,
          'shuffle_questions': shuffleQuestions,
          if (startedAt != null)
            'started_at': startedAt.toUtc().toIso8601String(),
          if (finishedAt != null)
            'finished_at': finishedAt.toUtc().toIso8601String(),
        },
        if (courseId != null)
          'attach_to_course': {'course_id': courseId},
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
    if (isPublic) {
      return request<void>(
        'riddler/v1/quizzes/$id/publish',
        method: HttpMethod.post,
        parser: (_) {},
      );
    }
    return request<void>(
      'riddler/v1/quizzes/$id',
      method: HttpMethod.patch,
      req: const {'is_public': false},
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

  @override
  Future<void> updateQuiz(
    String id, {
    String? title,
    String? description,
    Map<String, dynamic>? defaultSettings,
  }) {
    return request(
      'riddler/v1/quizzes/$id',
      method: HttpMethod.patch,
      req: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (defaultSettings != null) 'default_settings': defaultSettings,
      },
      parser: (_) {},
    );
  }

  @override
  Future<String> addQuestion(String quizId, Map<String, dynamic> questionData) {
    return request(
      'riddler/v1/quizzes/$quizId/questions',
      method: HttpMethod.post,
      req: questionData,
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  @override
  Future<void> removeQuestion(String quizId, String questionId) {
    return request(
      'riddler/v1/quizzes/$quizId/questions/$questionId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<String> createTestSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? totalTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return request<String>(
      'riddler/v1/sessions/test/inline',
      method: HttpMethod.post,
      req: {
        'title': title,
        if (description != null) 'description': description,
        'course_id': courseId,
        'module_id': moduleId,
        'questions': questions,
        if (totalTimeLimitSec != null) 'total_time_limit_sec': totalTimeLimitSec,
        if (shuffleQuestions) 'shuffle_questions': shuffleQuestions,
        if (startedAt != null) 'started_at': startedAt.toUtc().toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt.toUtc().toIso8601String(),
      },
      parser: (data) =>
          (data as Map<String, dynamic>)['session_id'] as String,
    );
  }

  @override
  Future<String> createLiveSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? questionTimeLimitSec,
  }) {
    return request<String>(
      'riddler/v1/sessions/live/inline',
      method: HttpMethod.post,
      req: {
        'title': title,
        if (description != null) 'description': description,
        'course_id': courseId,
        'module_id': moduleId,
        'questions': questions,
        if (questionTimeLimitSec != null)
          'question_time_limit_sec': questionTimeLimitSec,
      },
      parser: (data) =>
          (data as Map<String, dynamic>)['session_id'] as String,
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

  @override
  Future<void> generateQuizQuestions(String quizId, String sourceText) {
    return request<void>(
      'riddler/v1/quizzes/$quizId/generate',
      method: HttpMethod.post,
      req: {'text': sourceText},
      parser: (_) {},
    );
  }
}
