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
  final String channel;

  const SendOtpEvent(this.phone, {this.channel = 'sms'});

  @override
  List<Object?> get props => [phone, channel];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class RegisterEvent extends AuthEvent {
  final String phone;
  final String name;
  final String surname;

  const RegisterEvent({
    required this.phone,
    required this.name,
    required this.surname,
  });

  @override
  List<Object?> get props => [phone, name, surname];
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

class SwitchToRoleEvent extends AuthEvent {
  final String role; // "student" | "teacher"

  const SwitchToRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}
