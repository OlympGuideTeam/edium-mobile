class OtpSendRequest {
  final String phone;
  final Channel channel;

  const OtpSendRequest({
    required this.phone,
    required this.channel,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'channel': channel.type_,
      };
}

class OtpVerifyRequest {
  final String phone;
  final int otp;

  OtpVerifyRequest({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}

sealed class VerifyOtpResult {}

class AuthTokensResult extends VerifyOtpResult {
  final AuthTokensResponse tokens;
  AuthTokensResult(this.tokens);
}

class RegistrationRequired extends VerifyOtpResult {
  final String registrationToken;
  RegistrationRequired(this.registrationToken);
}

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

class RegistrationTokenResponse {
  final String registrationToken;

  RegistrationTokenResponse({required this.registrationToken});

  factory RegistrationTokenResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationTokenResponse(
      registrationToken: json['registration_token'] as String,
    );
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refresh_token': refreshToken,
      };
}

class LogoutRequest {
  final String refreshToken;

  LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refresh_token': refreshToken,
      };
}

class RegisterRequest {
  final String name;
  final String surname;
  final String phone;

  RegisterRequest({
    required this.name,
    required this.surname,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'surname': surname,
        'phone': phone,
      };
}

enum Channel {
  tg('tg'),
  vk('vk'),
  sms('sms');

  final String type_;
  const Channel(this.type_);
}
