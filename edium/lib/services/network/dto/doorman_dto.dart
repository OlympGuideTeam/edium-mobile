class OtpSendRequest {
  final String phone;
  final Channel channel;

  const OtpSendRequest({
    required this.phone,
    required this.channel
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'channel': channel.type_
  };
}

class OtpVerifyRequest {
  final String phone;
  final int otp;

  OtpVerifyRequest({
    required this.phone,
    required this.otp
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'otp': otp
  };
}

class AuthTokensResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponse(
      accessToken: json['access_token'], 
      refreshToken: json['refresh_token'], 
      expiresIn: json['expires_in']
    );
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'refresh_token': refreshToken
  };
}

class RegisterRequest {
  final String name;
  final String surname;
  final String phone;

  RegisterRequest({
    required this.name, 
    required this.surname, 
    required this.phone
  });

  Map<String, dynamic> toJson() => {
    'name': name, 
    'surname': surname,
    'phone': phone
  };
}

enum Channel {
  max('max'),
  sms('sms');

  final String type_;
  const Channel(this.type_);
}