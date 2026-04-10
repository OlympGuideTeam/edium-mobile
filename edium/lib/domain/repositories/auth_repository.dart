abstract class IAuthRepository {
  Future<void> sendOtp({required String phone, required String channel});
  Future<bool> verifyOtp({required String phone, required String otp});
  Future<void> register({required String phone, required String name, required String surname});
  Future<void> logout();
  Future<bool> isAuthenticated();
}
