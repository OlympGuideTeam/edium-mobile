import 'package:edium/domain/repositories/test_session_repository.dart';

class FinishTestAttemptUsecase {
  final ITestSessionRepository _repo;
  FinishTestAttemptUsecase(this._repo);

  Future<void> call({
    required String attemptId,
    required String sessionId,
  }) =>
      _repo.finishAttempt(attemptId: attemptId, sessionId: sessionId);
}
