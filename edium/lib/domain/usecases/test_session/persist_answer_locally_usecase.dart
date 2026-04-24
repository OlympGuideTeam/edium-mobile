import 'package:edium/domain/repositories/test_session_repository.dart';

class PersistAnswerLocallyUsecase {
  final ITestSessionRepository _repo;
  PersistAnswerLocallyUsecase(this._repo);

  Future<void> call({
    required String attemptId,
    required String sessionId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) =>
      _repo.submitAnswer(
        attemptId: attemptId,
        sessionId: sessionId,
        questionId: questionId,
        answerData: answerData,
      );
}
