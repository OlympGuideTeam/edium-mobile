import 'package:edium/domain/entities/awaiting_review_session.dart';
import 'package:edium/domain/repositories/awaiting_review_repository.dart';

class GetAwaitingReviewUsecase {
  final IAwaitingReviewRepository _repo;
  GetAwaitingReviewUsecase(this._repo);

  Future<List<AwaitingReviewSession>> call() => _repo.getAwaitingReview();
}
