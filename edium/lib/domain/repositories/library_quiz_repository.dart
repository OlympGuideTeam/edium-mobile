import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';

abstract class ILibraryQuizRepository {
  Future<List<LibraryQuiz>> getPublicQuizzes({String? search});

  Future<LibraryQuiz> getQuizForStudent(String id);

  Future<QuizAttempt> createAttempt(String sessionId);

  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  });

  Future<void> finishAttempt(String attemptId);

  Future<AttemptResult> getAttemptResult(String attemptId);
}
