part of 'doorman_dto.dart';

class AuthTokensResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

