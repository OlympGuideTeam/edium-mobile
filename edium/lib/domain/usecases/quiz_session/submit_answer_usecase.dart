import 'package:edium/domain/repositories/quiz_session_repository.dart';

class SubmitAnswerUsecase {
  final IQuizSessionRepository _repository;

  SubmitAnswerUsecase(this._repository);

  Future<({bool correct, String? explanation})> call({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) {
    return _repository.submitAnswer(
      sessionId: sessionId,
      questionId: questionId,
      answer: answer,
    );
  }
}
