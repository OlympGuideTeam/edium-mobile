part of 'test_session_repository.dart';

class StartOrResumeResult {
  final QuizAttempt attempt;
  final Map<String, Map<String, dynamic>> cachedAnswers;
  final bool resumedFromCache;

  const StartOrResumeResult({
    required this.attempt,
    required this.cachedAnswers,
    required this.resumedFromCache,
  });
}

