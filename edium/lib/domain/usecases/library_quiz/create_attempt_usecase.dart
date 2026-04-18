import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';

class CreateAttemptUsecase {
  final ILibraryQuizRepository _repository;

  CreateAttemptUsecase(this._repository);

  Future<QuizAttempt> call(String sessionId) =>
      _repository.createAttempt(sessionId);
}
