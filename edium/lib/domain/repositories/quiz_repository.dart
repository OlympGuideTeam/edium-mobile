import 'package:edium/domain/entities/quiz.dart';

abstract class IQuizRepository {
  Future<List<Quiz>> getQuizzes({
    String scope,
    String? search,
    int page,
    int limit,
  });

  Future<Quiz> createQuiz({
    required String title,
    required String subject,
    required QuizSettings settings,
    required List<Map<String, dynamic>> questions,
  });

  Future<Quiz> getQuizById(String id);

  Future<({bool liked, int likesCount})> likeQuiz(String id);

  Future<Map<String, dynamic>> getQuizResults(String id);

  Future<void> updateQuizStatus(String id, String status);

  Future<void> deleteQuiz(String id);
}
