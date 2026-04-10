import 'package:edium/domain/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final IAuthRepository _repository;

  VerifyOtpUsecase(this._repository);

  Future<bool> call({required String phone, required String otp}) {
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}
