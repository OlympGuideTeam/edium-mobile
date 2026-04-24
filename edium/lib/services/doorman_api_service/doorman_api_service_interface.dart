import 'package:edium/services/doorman_api_service/doorman_dto.dart';

abstract class IDoormanApiService {
  Future<int> sendOtpRequest(OtpSendRequest req);
  Future<VerifyOtpResult> otpVerifyRequest(OtpVerifyRequest req);
  Future<AuthTokensResponse> registerRequest(RegisterRequest req, {required String registrationToken});
  Future<AuthTokensResponse> refreshTokensRequest(RefreshTokenRequest req);
  Future<void> logoutRequest(LogoutRequest req);
}
