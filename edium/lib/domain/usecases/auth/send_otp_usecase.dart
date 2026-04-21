import 'package:edium/domain/repositories/auth_repository.dart';

class SendOtpUsecase {
  final IAuthRepository _repository;

  SendOtpUsecase(this._repository);

  Future<int> call({required String phone, required String channel}) {
    return _repository.sendOtp(phone: phone, channel: channel);
  }
}
