import 'package:edium/domain/repositories/test_session_repository.dart';

class GradeSubmissionUsecase {
  final ITestSessionRepository _repo;
  GradeSubmissionUsecase(this._repo);

  Future<void> call({
    required String attemptId,
    required List<({String submissionId, double score, String? feedback})> grades,
  }) =>
      _repo.gradeAttempt(attemptId: attemptId, grades: grades);
}
