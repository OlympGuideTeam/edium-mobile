abstract class IAuthRepository {
  Future<void> sendOtp({required String phone});
  Future<void> verifyOtp({required String phone, required String otp});
  Future<void> logout();
  Future<bool> isAuthenticated();
}
