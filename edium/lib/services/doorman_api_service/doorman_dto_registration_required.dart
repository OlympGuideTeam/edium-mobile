part of 'doorman_dto.dart';

class RegistrationRequired extends VerifyOtpResult {
  final String registrationToken;
  RegistrationRequired(this.registrationToken);
}

