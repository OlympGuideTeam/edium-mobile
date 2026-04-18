import 'package:edium/domain/repositories/library_quiz_repository.dart';

class SubmitAttemptAnswerUsecase {
  final ILibraryQuizRepository _repository;

  SubmitAttemptAnswerUsecase(this._repository);

  Future<void> call({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) =>
      _repository.submitAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answerData: answerData,
      );
}
