import 'package:edium/domain/repositories/auth_repository.dart';

class LogoutUsecase {
  final IAuthRepository _repository;

  LogoutUsecase(this._repository);

  Future<void> call() => _repository.logout();
}
