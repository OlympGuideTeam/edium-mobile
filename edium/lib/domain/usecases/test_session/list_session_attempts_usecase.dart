import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';

class ListSessionAttemptsUsecase {
  final ITestSessionRepository _repo;
  ListSessionAttemptsUsecase(this._repo);

  Future<List<AttemptSummary>> call(String sessionId) =>
      _repo.listSessionAttempts(sessionId);
}
