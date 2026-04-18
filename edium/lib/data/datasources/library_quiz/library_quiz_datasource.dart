import 'package:edium/data/models/library_quiz_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';

abstract class ILibraryQuizDatasource {
  Future<List<LibraryQuizModel>> getPublicQuizzes({String? search});

  Future<LibraryQuizModel> getQuizForStudent(String id);

  Future<QuizAttemptModel> createAttempt(String sessionId);

  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  });

  Future<void> finishAttempt(String attemptId);

  Future<AttemptResultModel> getAttemptResult(String attemptId);
}
