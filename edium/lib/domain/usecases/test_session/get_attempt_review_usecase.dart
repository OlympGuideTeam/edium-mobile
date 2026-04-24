import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';

class GetAttemptReviewUsecase {
  final ITestSessionRepository _repo;
  GetAttemptReviewUsecase(this._repo);

  Future<AttemptReview> call(String attemptId) =>
      _repo.getAttemptReview(attemptId);
}
