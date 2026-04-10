import 'package:edium/services/doorman_api_service/doorman_api_service_interface.dart';
import 'package:edium/services/doorman_api_service/doorman_dto.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/endpoints.dart';
import 'package:edium/services/network/http_method.dart';

class DoormanApiService extends BaseApiService implements IDoormanApiService {
  DoormanApiService(super.dio);

  @override
  Future<void> sendOtpRequest(OtpSendRequest req) async {
    return request(
      DoormanEndpoints.otpSend.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (_) {},
    );
  }

  @override
  Future<VerifyOtpResult> otpVerifyRequest(OtpVerifyRequest req) async {
    return request(
      DoormanEndpoints.otpVerify.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        if (json.containsKey('registration_token')) {
          return RegistrationRequired(json['registration_token'] as String);
        }
        return AuthTokensResult(AuthTokensResponse.fromJson(json));
      },
    );
  }

  @override
  Future<AuthTokensResponse> registerRequest(
    RegisterRequest req, {
    required String registrationToken,
  }) async {
    return request(
      DoormanEndpoints.authRegister.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: {'X-Reg-Token': registrationToken},
      parser: (data) => AuthTokensResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthTokensResponse> refreshTokensRequest(RefreshTokenRequest req) async {
    return request(
      DoormanEndpoints.authTokensRefresh.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (data) => AuthTokensResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> logoutRequest(LogoutRequest req) async {
    return request(
      DoormanEndpoints.authLogout.path,
      method: HttpMethod.post,
      req: req.toJson(),
      headers: null,
      parser: (_) {},
    );
  }
}
