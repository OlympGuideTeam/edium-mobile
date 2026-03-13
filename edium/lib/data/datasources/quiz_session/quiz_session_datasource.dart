import 'package:edium/data/models/quiz_session_model.dart';

abstract class IQuizSessionDatasource {
  Future<QuizSessionModel> startSession(String quizId);
  Future<QuizSessionModel> getSession(String sessionId);
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  });
  Future<QuizSessionModel> completeSession(String sessionId);
  Future<List<QuizSessionModel>> getMySessions();
}
