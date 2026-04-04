import 'package:edium/domain/repositories/user_repository.dart';

class DeleteAccountUsecase {
  final IUserRepository _repository;

  DeleteAccountUsecase(this._repository);

  Future<void> call() => _repository.deleteAccount();
}
