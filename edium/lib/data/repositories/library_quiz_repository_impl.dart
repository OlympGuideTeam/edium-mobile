import 'package:edium/data/datasources/library_quiz/library_quiz_datasource.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';

class LibraryQuizRepositoryImpl implements ILibraryQuizRepository {
  final ILibraryQuizDatasource _datasource;

  LibraryQuizRepositoryImpl(this._datasource);

  @override
  Future<List<LibraryQuiz>> getPublicQuizzes({String? search}) async {
    final models = await _datasource.getPublicQuizzes(search: search);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LibraryQuiz> getQuizForStudent(String id) async {
    final model = await _datasource.getQuizForStudent(id);
    return model.toEntity();
  }

  @override
  Future<QuizAttempt> createAttempt(String sessionId) async {
    final model = await _datasource.createAttempt(sessionId);
    return model.toEntity();
  }

  @override
  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) =>
      _datasource.submitAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answerData: answerData,
      );

  @override
  Future<void> finishAttempt(String attemptId) =>
      _datasource.finishAttempt(attemptId);

  @override
  Future<AttemptResult> getAttemptResult(String attemptId) async {
    final model = await _datasource.getAttemptResult(attemptId);
    return model.toEntity();
  }
}
