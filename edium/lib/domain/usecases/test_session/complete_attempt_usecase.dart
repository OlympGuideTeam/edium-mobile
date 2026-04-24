import 'package:edium/domain/repositories/test_session_repository.dart';

class CompleteAttemptUsecase {
  final ITestSessionRepository _repo;
  CompleteAttemptUsecase(this._repo);

  Future<void> call(String attemptId) => _repo.completeAttempt(attemptId);
}
