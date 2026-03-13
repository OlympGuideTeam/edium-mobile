import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SendOtpEvent extends AuthEvent {
  final String phone;

  const SendOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class NameSubmittedEvent extends AuthEvent {
  final String name;

  const NameSubmittedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class RoleSelectedEvent extends AuthEvent {
  const RoleSelectedEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
