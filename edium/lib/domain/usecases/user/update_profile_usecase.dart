import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/repositories/user_repository.dart';

class UpdateProfileUsecase {
  final IUserRepository _repository;

  UpdateProfileUsecase(this._repository);

  Future<User> call({required String name, required String surname}) =>
      _repository.updateProfile(name: name, surname: surname);
}
