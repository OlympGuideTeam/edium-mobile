import 'package:edium/domain/entities/awaiting_review_session.dart';

abstract class IAwaitingReviewRepository {
  Future<List<AwaitingReviewSession>> getAwaitingReview();
}
