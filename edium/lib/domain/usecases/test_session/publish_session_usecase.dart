import 'package:edium/domain/repositories/test_session_repository.dart';

class PublishSessionUsecase {
  final ITestSessionRepository _repo;
  PublishSessionUsecase(this._repo);
  Future<void> call(String sessionId) => _repo.publishSession(sessionId);
}
