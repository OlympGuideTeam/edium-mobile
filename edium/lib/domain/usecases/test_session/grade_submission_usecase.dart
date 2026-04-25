import 'package:edium/domain/repositories/test_session_repository.dart';

class GradeSubmissionUsecase {
  final ITestSessionRepository _repo;
  GradeSubmissionUsecase(this._repo);

  Future<void> call({
    required String attemptId,
    required String submissionId,
    required double score,
    String? feedback,
  }) =>
      _repo.gradeSubmission(
        attemptId: attemptId,
        submissionId: submissionId,
        score: score,
        feedback: feedback,
      );
}
