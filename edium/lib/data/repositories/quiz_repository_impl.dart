import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/models/quiz_model.dart';
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
  Future<Quiz> createQuiz({
    required String title,
    required String subject,
    required QuizSettings settings,
    required List<Map<String, dynamic>> questions,
  }) async {
    final model = await _datasource.createQuiz(
      title: title,
      subject: subject,
      settings: QuizSettingsModel.fromEntity(settings).toJson(),
      questions: questions,
    );
    return model.toEntity();
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
  Future<void> updateQuizStatus(String id, String status) {
    return _datasource.updateQuizStatus(id, status);
  }

  @override
  Future<void> deleteQuiz(String id) {
    return _datasource.deleteQuiz(id);
  }
}
