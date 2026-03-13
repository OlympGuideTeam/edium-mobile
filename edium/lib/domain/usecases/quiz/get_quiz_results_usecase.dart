import 'package:edium/domain/repositories/quiz_repository.dart';

class GetQuizResultsUsecase {
  final IQuizRepository _repository;

  GetQuizResultsUsecase(this._repository);

  Future<Map<String, dynamic>> call(String id) {
    return _repository.getQuizResults(id);
  }
}
