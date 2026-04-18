import 'package:edium/domain/repositories/library_quiz_repository.dart';

class FinishAttemptUsecase {
  final ILibraryQuizRepository _repository;

  FinishAttemptUsecase(this._repository);

  Future<void> call(String attemptId) => _repository.finishAttempt(attemptId);
}
