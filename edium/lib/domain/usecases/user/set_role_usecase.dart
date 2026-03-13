import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/repositories/user_repository.dart';

class SetRoleUsecase {
  final IUserRepository _repository;

  SetRoleUsecase(this._repository);

  Future<User> call(UserRole role) => _repository.setRole(role);
}
