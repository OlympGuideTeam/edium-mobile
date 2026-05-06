import 'package:edium/data/models/awaiting_review_session_model.dart';

abstract class IAwaitingReviewDatasource {
  /// `GET /riddler/v1/sessions/awaiting-review`
  Future<List<AwaitingReviewSessionModel>> getAwaitingReview();
}
