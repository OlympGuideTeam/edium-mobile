import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';

class GetAttemptResultUsecase {
  final ILibraryQuizRepository _repository;

  GetAttemptResultUsecase(this._repository);

  Future<AttemptResult> call(String attemptId) =>
      _repository.getAttemptResult(attemptId);
}
