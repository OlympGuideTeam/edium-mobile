import 'package:edium/services/doorman_api_service/doorman_dto.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/endpoints.dart';
import 'package:edium/services/network/http_method.dart';

class DoormanApiService extends BaseApiService {
  DoormanApiService(super.dio);

  Future<void> sendOtpRequest(OtpSendRequest req) async {
    return request(
      DoormanEndpoints.otpSend.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (_) {}
    );
  }

  Future<AuthTokensResponse> otpVerifyRequest(OtpVerifyRequest req) async {
    return request(
      DoormanEndpoints.otpVerify.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (data) => AuthTokensResponse.fromJson(data)
    );
  }

  Future<AuthTokensResponse> registerRequest(RegisterRequest req) async {
    return request(
      DoormanEndpoints.authRegister.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (data) => AuthTokensResponse.fromJson(data)
    );
  }

  Future<AuthTokensResponse> refreshTokensRequest(RefreshTokenRequest req) async {
    return request(
      DoormanEndpoints.authTokensRefresh.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (data) => AuthTokensResponse.fromJson(data)
    );
  }

  Future<void> logoutRequest() async {
    return request(
      DoormanEndpoints.authLogout.path,
      method: HttpMethod.post,
      req: null,
      headers: null,
      parser: (_) {}
    );
  }
}