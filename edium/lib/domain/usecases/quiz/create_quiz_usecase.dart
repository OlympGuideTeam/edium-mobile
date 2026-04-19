import 'package:edium/domain/repositories/quiz_repository.dart';

class CreateQuizUsecase {
  final IQuizRepository _repository;

  CreateQuizUsecase(this._repository);

  Future<String> call({
    required String title,
    String? description,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    required List<Map<String, dynamic>> questions,
    String? moduleId,
  }) {
    return _repository.createQuiz(
      title: title,
      description: description,
      totalTimeLimitSec: totalTimeLimitSec,
      questionTimeLimitSec: questionTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
      questions: questions,
      moduleId: moduleId,
    );
  }
}
