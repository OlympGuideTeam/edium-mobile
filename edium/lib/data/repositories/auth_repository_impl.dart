import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service_interface.dart';
import 'package:edium/services/doorman_api_service/doorman_dto.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IDoormanApiService _doorman;
  final ITokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required IDoormanApiService doorman,
    required ITokenStorage tokenStorage,
  })  : _doorman = doorman,
        _tokenStorage = tokenStorage;

  @override
  Future<void> sendOtp({required String phone}) async {
    await _doorman.sendOtpRequest(
      OtpSendRequest(phone: phone, channel: Channel.tg),
    );
  }

  @override
  Future<void> verifyOtp({required String phone, required String otp}) async {
    final tokens = await _doorman.otpVerifyRequest(
      OtpVerifyRequest(phone: phone, otp: int.parse(otp)),
    );
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  @override
  Future<void> logout() async {
    await _doorman.logoutRequest();
    await _tokenStorage.deleteTokens();
  }

  @override
  Future<bool> isAuthenticated() => _tokenStorage.hasTokens();
}
