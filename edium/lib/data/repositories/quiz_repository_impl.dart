import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements IQuizRepository {
  final IQuizDatasource _datasource;

  QuizRepositoryImpl(this._datasource);

  @override
  Future<List<Quiz>> getQuizzes({
    String scope = 'global',
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final models = await _datasource.getQuizzes(
      scope: scope,
      search: search,
      page: page,
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<String> createQuiz({
    required String title,
    String? description,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    required List<Map<String, dynamic>> questions,
    String? moduleId,
  }) {
    return _datasource.createQuiz(
      title: title,
      description: description,
      totalTimeLimitSec: totalTimeLimitSec,
      questionTimeLimitSec: questionTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
      questions: questions,
      moduleId: moduleId,
    );
  }

  @override
  Future<String> createTestSession({
    required String quizTemplateId,
    required String moduleId,
    int? totalTimeLimitSec,
    bool shuffleQuestions = false,
  }) {
    return _datasource.createTestSession(
      quizTemplateId: quizTemplateId,
      moduleId: moduleId,
      totalTimeLimitSec: totalTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
    );
  }

  @override
  Future<String> createLiveSession({
    required String quizTemplateId,
    required String moduleId,
    int? questionTimeLimitSec,
  }) {
    return _datasource.createLiveSession(
      quizTemplateId: quizTemplateId,
      moduleId: moduleId,
      questionTimeLimitSec: questionTimeLimitSec,
    );
  }

  @override
  Future<Quiz> getQuizById(String id) async {
    final model = await _datasource.getQuizById(id);
    return model.toEntity();
  }

  @override
  Future<({bool liked, int likesCount})> likeQuiz(String id) async {
    final data = await _datasource.likeQuiz(id);
    return (
      liked: data['liked'] as bool,
      likesCount: data['likes_count'] as int,
    );
  }

  @override
  Future<Map<String, dynamic>> getQuizResults(String id) {
    return _datasource.getQuizResults(id);
  }

  @override
  Future<void> publishQuiz(String id, {required bool isPublic}) {
    return _datasource.publishQuiz(id, isPublic: isPublic);
  }

  @override
  Future<String> copyQuiz(String id) {
    return _datasource.copyQuiz(id);
  }

  @override
  Future<void> deleteQuiz(String id) {
    return _datasource.deleteQuiz(id);
  }
}
