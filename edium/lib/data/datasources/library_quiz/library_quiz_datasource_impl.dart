import 'package:edium/data/datasources/library_quiz/library_quiz_datasource.dart';
import 'package:edium/data/models/library_quiz_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class LibraryQuizDatasourceImpl extends BaseApiService
    implements ILibraryQuizDatasource {
  LibraryQuizDatasourceImpl(super.dio);

  @override
  Future<List<LibraryQuizModel>> getPublicQuizzes({String? search}) {
    return request(
      'riddler/v1/quizzes',
      method: HttpMethod.get,
      query: {
        'role': 'student',
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (data) => (data as List<dynamic>)
          .map((e) =>
              LibraryQuizModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<LibraryQuizModel> getQuizForStudent(String id) {
    return request(
      'riddler/v1/quizzes/$id',
      method: HttpMethod.get,
      query: {'role': 'student'},
      parser: (data) =>
          LibraryQuizModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<QuizAttemptModel> createAttempt(String sessionId) {
    return request(
      'riddler/v1/sessions/$sessionId/attempts',
      method: HttpMethod.post,
      parser: (data) =>
          QuizAttemptModel.fromJson(data as Map<String, dynamic>),
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
  Future<AttemptResultModel> getAttemptResult(String attemptId) {
    return request(
      'riddler/v1/attempts/$attemptId/review',
      method: HttpMethod.get,
      parser: (data) =>
          AttemptResultModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
