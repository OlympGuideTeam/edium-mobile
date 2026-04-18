import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/repositories/library_quiz_repository.dart';

class GetPublicQuizzesUsecase {
  final ILibraryQuizRepository _repository;

  GetPublicQuizzesUsecase(this._repository);

  Future<List<LibraryQuiz>> call({String? search}) =>
      _repository.getPublicQuizzes(search: search);
}
