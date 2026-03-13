import 'package:edium/domain/repositories/quiz_repository.dart';

class LikeQuizUsecase {
  final IQuizRepository _repository;

  LikeQuizUsecase(this._repository);

  Future<({bool liked, int likesCount})> call(String id) {
    return _repository.likeQuiz(id);
  }
}
