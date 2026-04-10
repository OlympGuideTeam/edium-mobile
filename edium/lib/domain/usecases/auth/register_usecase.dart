import 'package:edium/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final IAuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<void> call({
    required String phone,
    required String name,
    required String surname,
  }) {
    return _repository.register(phone: phone, name: name, surname: surname);
  }
}
