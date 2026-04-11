import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/repositories/auth_repository.dart';

class AuthRepositoryMock implements IAuthRepository {
  final ProfileStorage _profileStorage;
  bool _authenticated = false;

  AuthRepositoryMock(this._profileStorage);

  @override
  Future<void> sendOtp({required String phone, required String channel}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<bool> verifyOtp({required String phone, required String otp}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp != '123456') {
      throw Exception('Неверный код. Используйте 123456 для теста.');
    }
    _authenticated = true;
    final isNewUser = !_profileStorage.hasName;
    return isNewUser;
  }

  @override
  Future<void> register({
    required String phone,
    required String name,
    required String surname,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
