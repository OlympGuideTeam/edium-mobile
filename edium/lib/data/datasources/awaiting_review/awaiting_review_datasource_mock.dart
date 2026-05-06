import 'package:edium/data/datasources/awaiting_review/awaiting_review_datasource.dart';
import 'package:edium/data/models/awaiting_review_session_model.dart';

class AwaitingReviewDatasourceMock implements IAwaitingReviewDatasource {
  static const _sessions = [
    AwaitingReviewSessionModel(
      sessionId: 'mock-mon-sess-2',
      quizTemplateId: 'quiz-uuid-0002',
      quizTitle: 'Линейные уравнения',
      gradingCount: 1,
      gradedCount: 3,
      completedCount: 2,
    ),
    AwaitingReviewSessionModel(
      sessionId: 'mock-mon-sess-3',
      quizTemplateId: 'quiz-uuid-0003',
      quizTitle: 'Квадратные уравнения — итоговый тест',
      gradingCount: 0,
      gradedCount: 5,
      completedCount: 1,
    ),
  ];

  @override
  Future<List<AwaitingReviewSessionModel>> getAwaitingReview() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions;
  }
}
