part of 'doorman_dto.dart';

class RegistrationTokenResponse {
  final String registrationToken;

  RegistrationTokenResponse({required this.registrationToken});

  factory RegistrationTokenResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationTokenResponse(
      registrationToken: json['registration_token'] as String,
    );
  }
}

