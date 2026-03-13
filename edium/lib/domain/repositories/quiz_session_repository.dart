import 'package:edium/domain/entities/quiz_session.dart';

abstract class IQuizSessionRepository {
  Future<QuizSession> startSession(String quizId);
  Future<QuizSession> getSession(String sessionId);
  Future<({bool correct, String? explanation})> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  });
  Future<QuizSession> completeSession(String sessionId);
  Future<List<QuizSession>> getMySessions();
}
