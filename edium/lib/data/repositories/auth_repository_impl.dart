import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/services/doorman_api_service/doorman_api_service_interface.dart';
import 'package:edium/services/doorman_api_service/doorman_dto.dart';
import 'package:edium/services/token_storage/token_storage_interface.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IDoormanApiService _doorman;
  final ITokenStorage _tokenStorage;

  String? _pendingRegistrationToken;

  AuthRepositoryImpl({
    required IDoormanApiService doorman,
    required ITokenStorage tokenStorage,
  })  : _doorman = doorman,
        _tokenStorage = tokenStorage;

  @override
  Future<void> sendOtp({required String phone, required String channel}) async {
    final ch = Channel.values.firstWhere(
      (c) => c.type_ == channel,
      orElse: () => Channel.sms,
    );
    await _doorman.sendOtpRequest(OtpSendRequest(phone: phone, channel: ch));
  }

  @override
  Future<bool> verifyOtp({required String phone, required String otp}) async {
    final result = await _doorman.otpVerifyRequest(
      OtpVerifyRequest(phone: phone, otp: int.parse(otp)),
    );
    switch (result) {
      case AuthTokensResult(:final tokens):
        await _tokenStorage.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        _pendingRegistrationToken = null;
        return false;
      case RegistrationRequired(:final registrationToken):
        _pendingRegistrationToken = registrationToken;
        return true;
    }
  }

  @override
  Future<void> register({
    required String phone,
    required String name,
    required String surname,
  }) async {
    final regToken = _pendingRegistrationToken;
    if (regToken == null) throw Exception('Сессия регистрации истекла. Начните заново');
    final tokens = await _doorman.registerRequest(
      RegisterRequest(name: name, surname: surname, phone: phone),
      registrationToken: regToken,
    );
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    _pendingRegistrationToken = null;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      await _doorman.logoutRequest(LogoutRequest(refreshToken: refreshToken));
    }
    await _tokenStorage.deleteTokens();
  }

  @override
  Future<bool> isAuthenticated() => _tokenStorage.hasTokens();
}
