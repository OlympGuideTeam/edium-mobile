part of 'doorman_dto.dart';

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

