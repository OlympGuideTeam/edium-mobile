part of 'doorman_dto.dart';

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

