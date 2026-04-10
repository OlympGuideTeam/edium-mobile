import 'package:edium/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial — app just launched, checking token
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  final String channel;

  const AuthOtpSent(this.phone, {this.channel = 'sms'});

  @override
  List<Object?> get props => [phone, channel];
}

/// Authenticated and has a role
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthNameRequired extends AuthState {
  final String phone;

  const AuthNameRequired(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Authenticated but role not yet chosen
class AuthRoleRequired extends AuthState {
  final User user;

  const AuthRoleRequired(this.user);

  @override
  List<Object?> get props => [user];
}

/// Not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
