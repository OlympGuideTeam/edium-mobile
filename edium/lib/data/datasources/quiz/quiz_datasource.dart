import 'package:edium/data/models/quiz_model.dart';

abstract class IQuizDatasource {
  Future<List<QuizModel>> getQuizzes({
    String scope,
    String? search,
    int page,
    int limit,
  });

  /// Returns quiz template id.
  Future<String> createQuiz({
    required String title,
    String? description,
    String? mode,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions,
    DateTime? startedAt,
    DateTime? finishedAt,
    required List<Map<String, dynamic>> questions,
    String? courseId,
  });

  /// Returns test session id.
  Future<String> createTestSession({
    required String quizTemplateId,
    required String moduleId,
    int? totalTimeLimitSec,
    bool shuffleQuestions,
    DateTime? startedAt,
    DateTime? finishedAt,
  });

  /// Returns live session id.
  Future<String> createLiveSession({
    required String quizTemplateId,
    required String moduleId,
    int? questionTimeLimitSec,
  });

  Future<QuizModel> getQuizById(String id);

  Future<Map<String, dynamic>> likeQuiz(String id);

  Future<Map<String, dynamic>> getQuizResults(String id);

  Future<void> publishQuiz(String id, {required bool isPublic});

  Future<String> copyQuiz(String id);

  Future<void> deleteQuiz(String id);

  Future<void> updateQuiz(
    String id, {
    String? title,
    String? description,
    Map<String, dynamic>? defaultSettings,
  });

  Future<String> addQuestion(String quizId, Map<String, dynamic> questionData);

  Future<void> removeQuestion(String quizId, String questionId);

  /// Creates quiz template + test session atomically (inline endpoint).
  Future<String> createTestSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? totalTimeLimitSec,
    bool shuffleQuestions,
    DateTime? startedAt,
    DateTime? finishedAt,
  });

  /// Creates quiz template + live session atomically (inline endpoint).
  Future<String> createLiveSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? questionTimeLimitSec,
  });

  Future<void> deleteSession(String sessionId);

  /// Запускает асинхерную генерацию вопросов по тексту (уведомление по готовности).
  Future<void> generateQuizQuestions(String quizId, String sourceText);
}
