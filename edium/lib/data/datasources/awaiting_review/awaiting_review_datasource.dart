import 'package:edium/data/models/awaiting_review_session_model.dart';

abstract class IAwaitingReviewDatasource {

  Future<List<AwaitingReviewSessionModel>> getAwaitingReview();
}
