part of 'test_session_datasource_mock.dart';

class _MockAttempt {
  final String attemptId;
  final String userId;
  final String status;
  final double? score;

  const _MockAttempt({
    required this.attemptId,
    required this.userId,
    required this.status,
    required this.score,
  });
}

