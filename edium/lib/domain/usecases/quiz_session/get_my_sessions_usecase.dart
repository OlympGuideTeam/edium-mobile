import 'package:edium/domain/entities/quiz_session.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';

class GetMySessionsUsecase {
  final IQuizSessionRepository _repository;

  GetMySessionsUsecase(this._repository);

  Future<List<QuizSession>> call() {
    return _repository.getMySessions();
  }
}
