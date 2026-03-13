import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';

class CreateQuizUsecase {
  final IQuizRepository _repository;

  CreateQuizUsecase(this._repository);

  Future<Quiz> call({
    required String title,
    required String subject,
    required QuizSettings settings,
    required List<Map<String, dynamic>> questions,
  }) {
    return _repository.createQuiz(
      title: title,
      subject: subject,
      settings: settings,
      questions: questions,
    );
  }
}
