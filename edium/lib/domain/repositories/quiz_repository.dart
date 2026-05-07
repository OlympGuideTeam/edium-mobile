import 'package:edium/domain/entities/quiz.dart';

abstract class IQuizRepository {
  Future<List<Quiz>> getQuizzes({
    String scope,
    String? search,
    int page,
    int limit,
  });

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

  Future<String> createTestSession({
    required String quizTemplateId,
    required String moduleId,
    int? totalTimeLimitSec,
    bool shuffleQuestions,
    DateTime? startedAt,
    DateTime? finishedAt,
  });

  Future<String> createLiveSession({
    required String quizTemplateId,
    required String moduleId,
    int? questionTimeLimitSec,
  });

  Future<Quiz> getQuizById(String id);

  Future<({bool liked, int likesCount})> likeQuiz(String id);

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

  Future<String> createLiveSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? questionTimeLimitSec,
  });

  Future<void> deleteSession(String sessionId);

  Future<void> generateQuizQuestions(String quizId, String sourceText);
}
