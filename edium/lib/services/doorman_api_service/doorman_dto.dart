
part 'doorman_dto_otp_verify_request.dart';
part 'doorman_dto_verify_otp_result.dart';
part 'doorman_dto_auth_tokens_result.dart';
part 'doorman_dto_registration_required.dart';
part 'doorman_dto_auth_tokens_response.dart';
part 'doorman_dto_registration_token_response.dart';
part 'doorman_dto_refresh_token_request.dart';
part 'doorman_dto_logout_request.dart';
part 'doorman_dto_register_request.dart';

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

