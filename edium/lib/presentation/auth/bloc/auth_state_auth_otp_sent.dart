part of 'auth_state.dart';

class AuthOtpSent extends AuthState {
  final String phone;
  final String channel;
  final int retryAfter;

  const AuthOtpSent(this.phone, {this.channel = 'sms', this.retryAfter = 180});

  @override
  List<Object?> get props => [phone, channel, retryAfter];
}

