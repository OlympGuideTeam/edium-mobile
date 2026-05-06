import 'package:edium/data/datasources/awaiting_review/awaiting_review_datasource.dart';
import 'package:edium/domain/entities/awaiting_review_session.dart';
import 'package:edium/domain/repositories/awaiting_review_repository.dart';

class AwaitingReviewRepositoryImpl implements IAwaitingReviewRepository {
  final IAwaitingReviewDatasource _datasource;

  AwaitingReviewRepositoryImpl(this._datasource);

  @override
  Future<List<AwaitingReviewSession>> getAwaitingReview() async {
    final models = await _datasource.getAwaitingReview();
    return models.map((m) => m.toEntity()).toList();
  }
}
