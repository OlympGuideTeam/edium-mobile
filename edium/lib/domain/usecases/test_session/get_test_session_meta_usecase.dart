import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';

class GetTestSessionMetaUsecase {
  final ITestSessionRepository _repo;
  GetTestSessionMetaUsecase(this._repo);

  Future<TestSessionMeta> call({
    required String quizId,
    String? sessionIdFallback,
  }) =>
      _repo.getSessionMeta(
          quizId: quizId, sessionIdFallback: sessionIdFallback);
}
