import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';

class GetQuizForStudentUsecase {
  final ILibraryQuizRepository _repository;

  GetQuizForStudentUsecase(this._repository);

  Future<LibraryQuiz> call(String id) => _repository.getQuizForStudent(id);
}
