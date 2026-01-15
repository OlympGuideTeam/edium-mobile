import 'package:edium/services/doorman_api_service/doorman_dto.dart';

abstract class IDoormanApiService {
  Future<void> sendOtpRequest(OtpSendRequest req);
  Future<AuthTokensResponse> otpVerifyRequest(OtpVerifyRequest req);
  Future<AuthTokensResponse> registerRequest(RegisterRequest req);
  Future<AuthTokensResponse> refreshTokensRequest(RefreshTokenRequest req);
  Future<void> logoutRequest();
}