part of 'auth_event.dart';

class SendOtpEvent extends AuthEvent {
  final String phone;
  final String channel;

  const SendOtpEvent(this.phone, {this.channel = 'sms'});

  @override
  List<Object?> get props => [phone, channel];
}

