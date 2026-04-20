import 'package:edium/domain/repositories/quiz_repository.dart';

enum SessionType { test, live }

class CreateSessionUsecase {
  final IQuizRepository _repository;

  CreateSessionUsecase(this._repository);

  Future<String> call({
    required String quizTemplateId,
    required String moduleId,
    required SessionType sessionType,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    if (sessionType == SessionType.live) {
      return _repository.createLiveSession(
        quizTemplateId: quizTemplateId,
        moduleId: moduleId,
        questionTimeLimitSec: questionTimeLimitSec,
      );
    }
    return _repository.createTestSession(
      quizTemplateId: quizTemplateId,
      moduleId: moduleId,
      totalTimeLimitSec: totalTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }
}
