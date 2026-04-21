import 'package:edium/domain/repositories/quiz_repository.dart';

class CreateQuizUsecase {
  final IQuizRepository _repository;

  CreateQuizUsecase(this._repository);

  Future<String> call({
    required String title,
    String? description,
    String? mode,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
    required List<Map<String, dynamic>> questions,
    String? courseId,
  }) {
    return _repository.createQuiz(
      title: title,
      description: description,
      mode: mode,
      totalTimeLimitSec: totalTimeLimitSec,
      questionTimeLimitSec: questionTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
      startedAt: startedAt,
      finishedAt: finishedAt,
      questions: questions,
      courseId: courseId,
    );
  }
}
