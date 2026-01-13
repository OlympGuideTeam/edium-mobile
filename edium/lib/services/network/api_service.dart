import 'package:dio/dio.dart';
import 'package:edium/services/network/dto/doorman_dto.dart';
import 'package:edium/services/network/endpoints.dart';


class ApiService {
  final Dio _dio;
  ApiService(Dio dio) : _dio = dio;

  Future<void> sendOtpRequest(Map<String, dynamic> req) async {
    try {
      final _ = await _dio.post(DoormanEndpoints.otpSend.path, data: req);
    } catch (e) {
      // TODO: Error handling
      if (e is DioException) {
        print('Error occurred: ${e.message}');
      }
    }
  }

  Future<AuthTokensResponse> otpVerifyRequest(Map<String, dynamic> req) async {
    try {
      final response = await _dio.post(DoormanEndpoints.otpVerify.path, data: req);
      return AuthTokensResponse.fromJson(response.data);
    } catch (e) {
      // TODO: Error handling
      throw e;
    }
  }

  Future<AuthTokensResponse> refreshTokensRequest(Map<String, dynamic> req) async {
    try {
      final response = await _dio.post(DoormanEndpoints.authRefresh.path, data: req);
      return AuthTokensResponse.fromJson(response.data);
    } catch(e) {
      // TODO: Error handling
      throw e;
    }
  }

  Future<AuthTokensResponse> registerRequest(Map<String, dynamic> req) async {
    try {
      final response = await _dio.post(DoormanEndpoints.authRegister.path, data: req);
      return AuthTokensResponse.fromJson(response.data);
    } catch (e) {
      // TODO: Error handling
      throw e;
    }
  }
}