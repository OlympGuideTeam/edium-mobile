import 'package:edium/domain/entities/quiz_session.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';

class CompleteQuizUsecase {
  final IQuizSessionRepository _repository;

  CompleteQuizUsecase(this._repository);

  Future<QuizSession> call(String sessionId) {
    return _repository.completeSession(sessionId);
  }
}
