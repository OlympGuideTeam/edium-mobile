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

/// OTP has been sent to phone
class AuthOtpSent extends AuthState {
  final String phone;

  const AuthOtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Authenticated and has a role
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authenticated but name not yet entered (first login)
class AuthNameRequired extends AuthState {
  final User user;

  const AuthNameRequired(this.user);

  @override
  List<Object?> get props => [user];
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
