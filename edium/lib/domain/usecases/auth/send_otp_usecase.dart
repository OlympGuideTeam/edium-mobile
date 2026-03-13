import 'package:edium/domain/repositories/auth_repository.dart';

class SendOtpUsecase {
  final IAuthRepository _repository;

  SendOtpUsecase(this._repository);

  Future<void> call({required String phone}) {
    return _repository.sendOtp(phone: phone);
  }
}
