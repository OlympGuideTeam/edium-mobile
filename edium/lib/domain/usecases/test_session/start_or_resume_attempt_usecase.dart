import 'package:edium/domain/repositories/test_session_repository.dart';

class StartOrResumeAttemptUsecase {
  final ITestSessionRepository _repo;
  StartOrResumeAttemptUsecase(this._repo);

  Future<StartOrResumeResult> call({
    required String sessionId,
    DateTime? deadline,
  }) =>
      _repo.startOrResumeAttempt(sessionId: sessionId, deadline: deadline);
}
