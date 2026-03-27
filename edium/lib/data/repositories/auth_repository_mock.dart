import 'package:edium/domain/repositories/auth_repository.dart';

/// Mock auth: any phone is accepted; OTP "1234" always passes.
class AuthRepositoryMock implements IAuthRepository {
  bool _authenticated = false;

  @override
  Future<void> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Always succeeds in mock
  }

  @override
  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp != '123456') {
      throw Exception('Неверный код. Используйте 123456 для теста.');
    }
    _authenticated = true;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _authenticated = false;
  }

  @override
  Future<bool> isAuthenticated() async => _authenticated;
}
