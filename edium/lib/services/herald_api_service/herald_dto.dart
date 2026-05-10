
part 'herald_dto_notification_item.dart';

class RegisterDeviceRequest {
  final String fcmToken;
  final String platform;

  const RegisterDeviceRequest({required this.fcmToken, required this.platform});

  Map<String, dynamic> toJson() => {
        'fcm_token': fcmToken,
        'platform': platform,
      };
}

