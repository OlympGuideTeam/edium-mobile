import 'package:edium/data/models/quiz_model.dart';

abstract class IQuizDatasource {
  Future<List<QuizModel>> getQuizzes({
    String scope,
    String? search,
    int page,
    int limit,
  });

  Future<QuizModel> createQuiz({
    required String title,
    required String subject,
    required Map<String, dynamic> settings,
    required List<Map<String, dynamic>> questions,
  });

  Future<QuizModel> getQuizById(String id);

  Future<Map<String, dynamic>> likeQuiz(String id);

  Future<Map<String, dynamic>> getQuizResults(String id);

  Future<void> updateQuizStatus(String id, String status);

  Future<void> deleteQuiz(String id);
}
