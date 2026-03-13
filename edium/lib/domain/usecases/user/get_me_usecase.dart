import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/repositories/user_repository.dart';

class GetMeUsecase {
  final IUserRepository _repository;

  GetMeUsecase(this._repository);

  Future<User> call() => _repository.getMe();
}
