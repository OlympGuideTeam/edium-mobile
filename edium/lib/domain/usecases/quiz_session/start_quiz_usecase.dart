import 'package:edium/domain/entities/quiz_session.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';

class StartQuizUsecase {
  final IQuizSessionRepository _repository;

  StartQuizUsecase(this._repository);

  Future<QuizSession> call(String quizId) {
    return _repository.startSession(quizId);
  }
}
