import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/domain/entities/quiz_session.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';

class QuizSessionRepositoryImpl implements IQuizSessionRepository {
  final IQuizSessionDatasource _datasource;

  QuizSessionRepositoryImpl(this._datasource);

  @override
  Future<QuizSession> startSession(String quizId) async {
    final model = await _datasource.startSession(quizId);
    return model.toEntity();
  }

  @override
  Future<QuizSession> getSession(String sessionId) async {
    final model = await _datasource.getSession(sessionId);
    return model.toEntity();
  }

  @override
  Future<({bool correct, String? explanation})> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) async {
    final data = await _datasource.submitAnswer(
      sessionId: sessionId,
      questionId: questionId,
      answer: answer,
    );
    return (
      correct: data['correct'] as bool,
      explanation: data['explanation'] as String?,
    );
  }

  @override
  Future<QuizSession> completeSession(String sessionId) async {
    final model = await _datasource.completeSession(sessionId);
    return model.toEntity();
  }

  @override
  Future<List<QuizSession>> getMySessions() async {
    final models = await _datasource.getMySessions();
    return models.map((m) => m.toEntity()).toList();
  }
}
