import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';

class GetQuizzesUsecase {
  final IQuizRepository _repository;

  GetQuizzesUsecase(this._repository);

  Future<List<Quiz>> call({
    String scope = 'global',
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getQuizzes(
      scope: scope,
      search: search,
      page: page,
      limit: limit,
    );
  }
}
