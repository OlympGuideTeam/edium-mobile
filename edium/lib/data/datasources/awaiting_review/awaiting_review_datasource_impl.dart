import 'package:edium/data/datasources/awaiting_review/awaiting_review_datasource.dart';
import 'package:edium/data/models/awaiting_review_session_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class AwaitingReviewDatasourceImpl extends BaseApiService
    implements IAwaitingReviewDatasource {
  AwaitingReviewDatasourceImpl(super.dio);

  @override
  Future<List<AwaitingReviewSessionModel>> getAwaitingReview() {
    return request(
      'riddler/v1/sessions/awaiting-review',
      method: HttpMethod.get,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['sessions'] as List<dynamic>;
        return list
            .map((e) => AwaitingReviewSessionModel.fromJson(
                e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
